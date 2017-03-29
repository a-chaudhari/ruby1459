require 'socket'
require_relative 'router'
require 'observer'
require 'byebug'

class Irc
include Observable

  def initialize
    @s = nil
    @r = Router.new(@s)
  end

  def open
    @s = TCPSocket.new 'irc.freenode.net', 6667
  end

  def read
    Thread.new do
      loop{
        msg = @s.gets.chomp
        changed
        self.parse(msg)
        notify_observers(Time.now, )
      }
    end
  end

  def parse(msg)
    # puts msg
    chunks = msg.split(' ', 2)
    # p chunks
    first = chunks.shift
    # p first
    # if first == "PING"
    #   p "ponging!"
    #   write("PONG "+ chunks[1])
    # end
    # debugger
    @r.route(first,chunks)
  end

  def write(msg)
    @s.puts(msg)
  end

  def close
    @s.close
  end

end
