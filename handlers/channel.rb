def RPL_TOPIC(chunks, raw)
  p chunks
  topic = chunks.drop(4).join(' ')
  chan_str = chunks[3]
  @channels[chan_str].topic=topic
end

def TOPIC(chunks, raw)
  p chunks
  topic = chunks.drop(3).join(' ')
  chan_str = chunks[2]
  # debugger
  @channels[chan_str].topic=topic
end

def RPL_NAMREPLY(chunks, raw)
  p chunks
  chan = @channels[chunks[4]]
  # debugger
  chan.users.merge(chunks.drop(5))
end

def RPL_ENDOFNAMES(chunks, raw)
  chan = @channels[chunks[3]]
  p chan.users
  chan.status = :active
  chan.waiting = false
end

def JOIN(chunks, raw)
  chunks = raw.split(' ') #ipv6 workaround
  channel = chunks[2]
  channel_obj = @channels[channel]
  user_str = chunks[0]
  user = user_str.split('!',2).first

  # channel_obj.users.add(user)
  # debugger
  channel_obj._recv(:userlist_changed,nil)
  channel_obj._recv(:chan_join,
                      {
                        user: user,
                        user_str: user_str,
                        channel: channel,
                        timestamp: Time.now
                        })
end

def QUIT(chunks, raw)
  chunks = raw.split(' ')
  quit_msg = chunks[2]
  quit_msg[0] = ''
  user_str = chunks[0]
  user_str[0] = ''
  user = user_str.split('!', 2).first

  @channels.each do |_, channel_obj|
    if channel_obj.users.include?(user)
      channel_obj.users.delete(user)
      channel_obj._recv(:userlist_changed, nil)
      channel_obj._recv(:chan_part,
                          {
                            user: user,
                            user_str: user_str,
                            channel: channel,
                            timestamp: Time.now,
                            quit_msg: quit_msg
                          })
    end
  end
end

def PART(chunks, raw)
  chunks = raw.split(' ')
  channel = chunks[2]
  channel_obj = @channels[channel]
  user_str = chunks[0]
  user_str[0] = ''
  user = user_str.split('!', 2).first

  return if channel_obj.nil?

  channel_obj.users.delete(user)
  channel_obj._recv(:userlist_changed, nil)
  channel_obj._recv(:chan_part,
                      {
                        user: user,
                        user_str: user_str,
                        channel: channel,
                        timestamp: Time.now,
                        quit_msg: ""
                      })
end
