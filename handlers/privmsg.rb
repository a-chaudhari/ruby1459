def PRIVMSG(chunks, raw)
  target = chunks[2]
  chan = @channels[target]
  query = target == @nickname
  channel = query ? nil : chan.channel
  user_str = chunks[0]
  user = user_str.split('!', 2).first
  msg = chunks.drop(3).join(' ')

  emote = false
  if msg[0] == "\001"
    ctcp_payload = msg.split("\001").last
    chunks = ctcp_payload.split(' ')
    if chunks[0].casecmp('ACTION') == 0
      emote = true
      msg = chunks.drop(1).join(' ')
    else
      #silently drop any other CTCP for now
      return
    end
  end

  command = { user: user,
              channel: channel,
              user_str: user_str,
              msg: msg,
              emote: emote,
              timestamp: Time.now }

  if query
    emit(:query, command)
  else
    chan._recv(:chanmsg, command)
  end

end
