require 'events'
require 'set'

class IrcChannel
  include Events::Emitter

  def initialize(conn, channel)
    @conn = conn
    @channel = channel
    @status=:parted
    @waiting = true
    @users = Set.new
    @topic = ""
    @mode = ""
    #active, kicked, banned, invite_only
  end
  attr_accessor :waiting, :users, :status
  attr_reader :channel, :mode, :topic

  def join
    return if @status == :active
    @conn.write("JOIN #{@channel}")
    while @waiting
      sleep(1)
    end
    @status
  end

  def topic=(topic)
    return if topic == @topic

    @topic=topic
    emit(:new_topic)
  end

  def part
    @status=:parted
    @waiting = true
    @users = Set.new
    @mode = ""
    @conn.write("PART #{@channel}")
  end

  def speak(msg)
    return unless @status == :active
    @conn.write("PRIVMSG #{@channel} :#{msg}")
  end

  def emote(msg)

  end

  def userlist
    @users.to_a
  end

  def _recv(type, data)
    # p @users
    emit(type, data)
  end

end
