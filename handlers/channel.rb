def RPL_TOPIC(chunks)
  p chunks
end

def RPL_NAMREPLY(chunks)
  p chunks
  chan = @channels[chunks[4]]
  chan.users.merge(chunks.drop(5))
end

def RPL_ENDOFNAMES(chunks)
  chan = @channels[chunks[3]]
  p chan.users
  chan.status = :active
  chan.waiting = false
end

def JOIN(chunks)
  channel = chunks[2]
  channel_obj = @channels[channel]
  user_str = chunks[0]
  user = user_str.split('!',2).first

  channel_obj.users.add(user)
  channel_obj._recv(:userlist_changed,nil)
  channel_obj._recv(:chan_join,
                      {
                        user: user,
                        user_str: user_str,
                        channel: channel,
                        timestamp: Time.now
                        })
end

def PART(chunks)
  channel = chunks[2]
  channel_obj = @channels[channel]
  user_str = chunks[0]
  user = user_str.split('!',2).first

  channel_obj.users.delete(user)
  channel_obj._recv(:userlist_changed,nil)
  channel_obj._recv(:chan_part,
                      {
                        user: user,
                        user_str: user_str,
                        channel: channel,
                        timestamp: Time.now,
                        quit_msg: quit_msg
                        })
end
