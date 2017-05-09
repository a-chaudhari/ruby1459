require 'events'
require 'set'

class IrcChannel
  include Events::Emitter

  def initialize(conn, channel)

    if channel[0] =~ /\w/
      raise "channel name is not valid"
    end

    @conn = conn
    @channel = channel
    @status = :parted
    @waiting = true
    @users = {}
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

    @topic = topic
    command = { channel: @channel,
                timestamp: Time.now,
                topic: @topic }

    emit(:new_topic, command)
  end

  def part
    @status = :parted
    @waiting = true
    @users = {}
    @mode = ""
    @conn.write("PART #{@channel}")
  end

  def speak(msg)
    return unless @status == :active
    @conn.write("PRIVMSG #{@channel} :#{msg}")
  end

  def emote(msg)
    return unless @status == :active
    @conn.write("PRIVMSG #{@channel} :\001ACTION #{msg} \001")
  end

  def userlist
    @users.keys
  end

  def _recv(type, data)
    emit(type, data)
  end

end
