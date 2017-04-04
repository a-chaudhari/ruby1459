require 'events'

class IrcChannel
  def initialize(conn, channel)
    @conn = conn
    @channel = channel
    @status=:parted
    @waiting = true
    #active, kicked, banned, invite_only
  end
  attr_accessor :waiting

  def join
    return if @status == :active
    @conn.write("JOIN #{channel}")
    while @waiting
      sleep(1)
    end
  end

  def part

  end

  def speak(msg)

  end

  def emote(msg)

  end

  def user_list

  end

  def _recv(chunks)

  end

end
