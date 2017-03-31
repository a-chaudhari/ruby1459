require_relative 'IrcConnection'
# Thread.abort_on_exception = true

class Test
  def initialize
    irc = IrcConnection.new({
        server:"irc.freenode.net",
        nickname:"test2348922"
      })

    irc.on(:raw) do |msg|
      # chunks =  msg.split(' ')
      # p chunks
    end

    irc.on(:connection_error) do
      puts "connection failed"
      return
    end

    irc.on(:connected) do
      puts "connected!"
    end

    irc.connect

    while true
      line = gets.chomp
      chunks = line.split(' ', 2)
      irc.write(line)
      cmd = chunks.shift

    end

  end

end


test = Test.new
