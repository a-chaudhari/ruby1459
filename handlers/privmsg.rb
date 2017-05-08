def privmsg(chunks, raw)
  chunks = raw.split(' ')
  target = chunks[2]
  if target == @nickname
    handle_query(chunks, raw)
  else
    chan = @channels[target]
    user_str = chunks[0]
    user_str[0]='' if user_str[0] == ':'
    user = user_str.split('!', 2).first
    msg=raw.split(':', 3).last
    msg[0] = '' if msg[0] == ':'
    chan._recv(:chanmsg,
                  { user: user,
                  channel: chan.channel,
                  user_str: user_str,
                  msg: msg,
                  timestamp: Time.now})
  end
end

def handle_query(chunks, raw)
  user_str = chunks[0]
  user_str[0] = '' if user_str[0] == ":"
  msg=raw.split(':',3).last
  msg[0] = '' if msg[0] == ':'
  user = user_str.split('!', 2).first
  emit(:query,{ user: user,
                user_str: user_str,
                msg: msg,
                timestamp: Time.now })
end
