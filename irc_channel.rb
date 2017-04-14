require 'events'

class IrcChannel
  include Events::Emitter

  def initialize(conn, channel)
    @conn = conn
    @channel = channel
    @status=:parted
    @waiting = true
    @users = []
    @mode = ""
    #active, kicked, banned, invite_only
  end
  attr_accessor :waiting, :users, :status
  attr_reader :channel, :users, :mode

  def join
    return if @status == :active
    @conn.write("JOIN #{@channel}")
    while @waiting
      sleep(1)
    end
    @status
  end

  def part
    @status=:parted
    @waiting = true
    @users = []
    @mode = ""
    @conn.write("PART #{@channel}")
  end

  def speak(msg)
    return unless @status == :active
    @conn.write("PRIVMSG #{@channel} :#{msg}")
  end

  def emote(msg)

  end

  def _recv(data)
    emit(:chanmsg,data)
  end

end
