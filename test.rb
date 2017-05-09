require_relative 'irc_connection'
require 'byebug'
Thread.abort_on_exception = true

class Test
  def initialize
    irc = IrcConnection.new({
        # server:"irc.prison.net",
        server:"irc.freenode.net",
        nickname:"zelos82"
      })

    # irc.on(:raw) do |msg|
    #   # chunks =  msg.split(' ')
    #   # p chunks
    # end

    irc.on(:connection_error) do
      puts "connection failed"
      return
    end

    irc.on(:connected) do
      puts "connected!"
    end

    irc.on(:ERR_NOSUCHNICK) do |obj|
      puts "yay error hooked  "
      p obj

    end

    irc.on(:registered) do
      puts "registered!"
      ['#test1115'].each do |name|
        chan = irc.createChannel(name)
        chan.on(:chanmsg) do |data|
          puts "#{data[:channel]} #{data[:user]}: #{data[:msg]}"
        end
        res = chan.join
        # chan.speak("yo")
      end
      # irc.query('tet823302','test')

    end

    # irc.on(:raw) {|msg| p msg}

    irc.connect

    while true
      # line = gets.chomp
      # chunks = line.split(' ', 2)
      # irc.write(line)
      # cmd = chunks.shift
      sleep(1000)

    end

  end

end


test = Test.new
