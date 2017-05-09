def RPL_TOPIC(chunks, raw)
  topic = chunks.drop(4).join(' ')
  chan_str = chunks[3]
  @channels[chan_str].topic = topic
end

def TOPIC(chunks, raw)
  topic = chunks.drop(3).join(' ')
  chan_str = chunks[2]
  @channels[chan_str].topic = topic
end

def RPL_NAMREPLY(chunks, raw)
  chan = @channels[chunks[4]]
  chan.users.merge(chunks.drop(5))
end

def RPL_ENDOFNAMES(chunks, raw)
  chan = @channels[chunks[3]]
  chan.status = :active
  chan.waiting = false
end

def JOIN(chunks, raw)
  channel = chunks[2]
  channel_obj = @channels[channel]

  if channel_obj.nil?
    puts "Forced join detected! " + raw
    return
  end

  user_str = chunks[0]
  user = user_str.split('!', 2).first

  channel_obj.users.add(user)
  channel_obj._recv(:userlist_changed, nil)
  command = {
    user: user,
    user_str: user_str,
    channel: channel,
    timestamp: Time.now
  }
  channel_obj._recv(:chan_join, command)
end

def QUIT(chunks, raw)
  quit_msg = chunks.drop(2).join(' ')
  user_str = chunks[0]
  user = user_str.split('!', 2).first

  @channels.each do |_, channel_obj|
    if channel_obj.users.include?(user)
      channel_obj.users.delete(user)
      channel_obj._recv(:userlist_changed, nil)
      command = {
        user: user,
        user_str: user_str,
        channel: channel_obj.channel,
        timestamp: Time.now,
        quit_msg: quit_msg
      }
      channel_obj._recv(:chan_part, command)
    end
  end
end

def PART(chunks, raw)
  channel = chunks[2]
  channel_obj = @channels[channel]
  user_str = chunks[0]
  user = user_str.split('!', 2).first

  return if channel_obj.nil?

  channel_obj.users.delete(user)
  channel_obj._recv(:userlist_changed, nil)
  command = {
    user: user,
    user_str: user_str,
    channel: channel,
    timestamp: Time.now,
    quit_msg: ""
  }
  channel_obj._recv(:chan_part, command)
end
