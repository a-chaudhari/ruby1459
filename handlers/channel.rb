def JOIN(chunks, raw)
  channel = chunks[2]
  channel_obj = @channels[channel]

  if channel_obj.nil?
    # this is a server-pushed join.  probably when connecting to a bouncer
    # or maybe an overflow channel?
    channel_obj = createChannel(channel)
    channel_obj.status = :active
    emit(:forced_chan_join, channel)
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
