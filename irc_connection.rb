require 'events'
require 'socket'
require 'byebug'
require_relative 'irc_channel'
require_relative 'responses'
require_relative 'handlers/ping'
require_relative 'handlers/motd'
require_relative 'handlers/channel'

class IrcConnection
  include Events::Emitter

  def initialize(options)
    #takes an options hash
    @server = options[:server] ||= "irc.freenode.net" #freenode for testing
    @port = options[:port] ||= 6667
    @password = options[:password] ||= ""
    @nickname = options[:nickname] ||= "defNick73249"
    @username = options[:username] ||= "user"
    @realname = options[:realname] ||= "User Name"
    @channels = []
    @conn = nil
    @server_motd = ""

    @status = :disconnected
    @realserver = nil
    @timeout_timer = nil
    @timeout =  300000
    @nickTaken = false;
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
    p args[0]
  end

  def write(msg)
    p "writing: " + msg
    @conn.puts(msg)
  end

  def parse(msg)

    if @realserver.nil?
      @realserver = msg.split(' ', 2).first
      puts "setting realserver to: #{@realserver}"
    end
    chunks = msg.split(' ')
    cmd = extract_command(chunks)
    # p cmd
    # p msg

    emit(cmd, chunks)
    send(cmd, chunks)
  end

  def extract_command(chunks)
    cmd_idx = chunks.find_index do |el|
      !el.start_with?(@realserver) && !el.start_with?(":#{@nickname}")
    end

    str = chunks[cmd_idx]
    REPLIES[str] ? REPLIES[str] : str
  end

  def disconnect
    emit(:disconnecting)
    @conn.close
    emit(:disconnected)
  end

  def createChannel(channel)
    chan = IrcChannel.new(self, channel)
    @channels.push(chan)
    chan
  end

  def joinedChannels
    @channels
  end
end
