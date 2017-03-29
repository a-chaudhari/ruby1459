require 'socket'
require_relative 'router'

class Irc

  def initalize
    @s = nil
  end

  def open
    @s = TCPSocket.new 'irc.freenode.net', 6667
  end

  def read
    Thread.new do
      loop{
        msg = @s.gets.chomp
        # puts msg
        parse(msg)
      }
    end
  end

  def parse(msg)
    # puts msg
    chunks = msg.split(' ', 2)
    p chunks
    first = chunks[0]
    if first == "PING"
      p "ponging!"
      write("PONG "+ chunks[1])
    end
  end

  def write(msg)
    @s.puts(msg)
  end

  def close
    @s.close
  end

end
