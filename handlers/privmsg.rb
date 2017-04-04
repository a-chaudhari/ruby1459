def privmsg(chunks)
  target = chunks[2]
  if target == @nickname
    handle_query(chunks)
  else
    chan = @channels[target]
    user_str = chunks[0]
    user_str[0]=''
    msg=chunks.drop(3).join(" ")
    msg[0]=''
    user = user_str.split('!', 2).first
    chan._recv({ user: user,
                channel: chan.channel,
                user_str: user_str,
                msg: msg,
                timestamp: Time.now})
  end
end

def handle_query(chunks)
  user_str = chunks[0]
  user_str[0]=''
  msg=chunks[3]
  msg[0]=''
  user = user_str.split('!', 2).first
  emit(:query,{ user: user,
                user_str: user_str,
                msg: msg,
                timestamp: Time.now })
end
