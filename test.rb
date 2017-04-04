require_relative 'irc_connection'
Thread.abort_on_exception = true

class Test
  def initialize
    irc = IrcConnection.new({
        server:"irc.freenode.net",
        nickname:"zello82"
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

    irc.on(:registered) do
      puts "registered!"
      ['#test1234'].each do |name|
        chan = irc.createChannel(name)
        chan.on(:chanmsg) do |data|
          puts "#{data[:channel]} #{data[:user]}: #{data[:msg]}"
        end
        res = chan.join
        chan.speak("yo")
        p res
      end
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
