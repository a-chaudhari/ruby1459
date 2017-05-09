require 'events'
require 'socket'
require 'time'
require_relative 'irc_channel'
require_relative 'responses'
require_relative 'handlers/ping'
require_relative 'handlers/motd'
require_relative 'handlers/channel'
require_relative 'handlers/privmsg'
require_relative 'handlers/nickname'
require_relative 'handlers/topic'
require_relative 'handlers/userlist'

class IrcConnection
  include Events::Emitter

  def initialize(options)
    #takes an options hash
    @server = options[:server] ||= nil
    @port = options[:port] ||= 6667
    @password = options[:password] ||= ""
    @nickname = options[:nickname] ||= nil
    @username = options[:username] ||= "user"
    @realname = options[:realname] ||= "User Name"
    @channels = {}
    @conn = nil
    @server_motd = ""

    @status = :disconnected
    @realserver = nil
    @timeout_timer = nil
    @timeout = 300000
  end

  attr_reader :channels, :server, :nickname, :port, :username,
              :realname, :server_motd, :status

  def emit(event, *args)
    Thread.new do
      super
    end
  end

  def validate_url
    if @server.nil?
      emit(:connection_error)
      raise "server field cannot be nil"
    end

    if @nickname.nil?
      emit(:connection_error)
      raise "nickname field cannot be nil"
    elsif @nickname.length < 3
      emit(:connection_error)
      raise "nickname must be at least 3 characters long"
    end

    @port = @port.to_i
    unless @port.is_a?(Integer) && @port > 0 && @port < 65535
      emit(:connection_error)
      raise "port must be an integer greater than 0 and less than 65535"
    end
  end

  def connect
    emit(:connecting)

    validate_url

    begin
      @conn = TCPSocket.new @server, @port
    rescue SocketError
      emit(:connection_error)
      return
    end

    self.restart_timer
    emit(:connected)
    self.read

    emit(:registering)
    self.write("PASS #{@password}") unless @password == ""
    self.write("NICK #{@nickname}")
    self.write("USER #{@username} * * :#{@realname}")
  end

  def restart_timer
    @timeout_timer.kill unless @timeout_timer.nil?
    @timeout_timer = Thread.new do
      sleep @timeout
      self.timeout_reached
    end
  end

  def timeout_reached
    @read_thread.kill
    emit(:disconnected)
    @status = :disconnected
  end

  def query(nickname, msg)
    write("PRIVMSG #{nickname} #{msg}")
  end

  def read
    @read_thread = Thread.new do
      loop do
        begin
          msg = @conn.gets
        rescue IOError
          emit(:disconnected)
          @status = :disconnected0
          puts 'disconnected due to IOError'
          break
        end

        break if msg.nil?
        self.restart_timer
        msg = msg.chomp
        emit(:raw, msg)
        self.parse(msg)
      end
      @status = :disconnected
      emit(:disconnected)
      # debugger
    end
  end

  def method_missing(m, *args)
    puts "Response #{m} is not handled"
  end

  def write(msg)
    puts "writing: " + msg
    begin
      @conn.puts(msg)
    rescue IOError
      emit(:disconnected)
      @status = :disconnected
      puts 'disconnected'
    end
  end

  def parse(msg)
    msg[0] = '' if msg[0] == ':'
    chunks = []
    msg.split(' :', 2).each do |el|
      chunks += el.split(' ')
    end

    if @realserver.nil?
      @realserver = chunks.first
      puts "setting realserver to: #{@realserver}"
    end
    cmd = extract_command(chunks)

    if cmd.nil?
      puts "Command extraction failed: " + msg
      return
    end

    emit(cmd, msg)
    send(cmd, chunks, msg)
  end

  def extract_command(chunks)
    str = chunks.find { |el| !REPLIES[el].nil? }
    str ? REPLIES[str] : nil
  end

  def disconnect
    emit(:disconnecting)
    @conn.close
  end

  def createChannel(channel)
    chan = IrcChannel.new(self, channel)
    @channels[channel] = chan
    chan
  end

  def deleteChannel(channel)
    @channels[channel].part
    @channels.delete(channel)
  end

end
