require 'events'
require 'socket'
# require 'byebug'
require 'time'
require_relative 'irc_channel'
require_relative 'responses'
require_relative 'handlers/ping'
require_relative 'handlers/motd'
require_relative 'handlers/channel'
require_relative 'handlers/privmsg'
require_relative 'handlers/userlist'

class IrcConnection
  include Events::Emitter

  def initialize(options)
    #takes an options hash
    @server = options[:server] ||= nil #freenode for testing
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
    @timeout =  300000
    @nickTaken = false;
  end

  attr_reader :channels, :server, :nickname, :port, :username, :realname, :server_motd, :status

  def emit(event, *args)
    Thread.new do
      super
    end
  end

  def connect
    emit(:connecting)
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
    #TODO handle taken nicks
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
      loop{
        msg = @conn.gets
        break if msg.nil?
        self.restart_timer
        msg = msg.chomp
        emit(:raw, msg)
        self.parse(msg)
      }
      @status = :disconnected
      emit(:disconnected)
      # debugger
    end
  end

  def method_missing(m, *args)
    puts "Response #{m} is not handled"
    p args
  end

  def write(msg)
    p "writing: " + msg
    @conn.puts(msg)
  end

  def parse(msg)

    chunks = []
    msg.split(':',3).each do |el|
      chunks += el.split(' ')
    end

    if @realserver.nil?
      @realserver = chunks.first
      puts "setting realserver to: #{@realserver}"
    end
    cmd = extract_command(chunks)
    # p cmd
    # p msg

    emit(cmd, chunks, msg)
    send(cmd, chunks, msg)
  end

  def extract_command(chunks)
    str = chunks.find {|el| !REPLIES[el].nil?}
    str ? REPLIES[str] : chunks.join(' ')
  end

  def disconnect
    emit(:disconnecting)
    @conn.close
    emit(:disconnected)
  end

  def createChannel(channel)
    chan = IrcChannel.new(self, channel)
    @channels[channel]=chan
    chan
  end

  def deleteChannel(channel)
    @channels[channel].part
    @channels.delete(channel)
  end

end
