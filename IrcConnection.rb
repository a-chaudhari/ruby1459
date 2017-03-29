# require_relative 'irc'
require 'events'
require 'socket'
require 'byebug'

class IrcConnection
  # include Observable
  include Events::Emitter

  def initialize(options)
    #takes an options hash
    @server = options[:server] ||= ""
    @port = options[:port] ||= 6667
    @password = options[:password] ||= ""
    @nickname = options[:nickname] ||= "defNick73249"
    @username = options[:username] ||= "user"
    @realname = options[:realname] ||= "User Name"
    @channels = []
    @conn = nil

    @realserver = nil
  end

  def connect
    emit(:connecting)
    begin
      @conn = TCPSocket.new @server, @port
    rescue SocketError
      emit(:connection_error)
      return
    end
    emit(:connected)
    self.read

    emit(:registering)
    self.write("PASS #{@password}") unless @password == ""
    self.write("NICK #{@nickname}")
    #TODO handle taken nicks
    self.write("USER #{@username} * * :#{@realname}")


  end

  def read
    Thread.new do
      loop{
        msg = @conn.gets.chomp
        emit(:raw, msg)
        self.parse(msg)
      }
    end
  end

  def write(msg)
    @conn.puts(msg)
  end

  def parse(msg)
    chunks = msg.split(' ')

    first = chunks.first
    if @realserver.nil?
      @realserver = first
      puts "setting realserver to: #{@realserver}"
    end

    cmd_idx = chunks.find_index do |el|
      el != @realserver && el != ":#{@nickname}"
    end

    cmd = chunks.slice!(cmd_idx)
    p "command: " + cmd
    p chunks

    if cmd == "PING"
      self.write("PONG #{chunks}")
    end

  end

  def disconnect
    emit(:disconnecting)
    @conn.close
  end

  def joinChannel(channel)

  end

  def joinedChannels
    @channels
  end
end
