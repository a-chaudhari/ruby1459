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

# def handle_query(chunks, raw)
#   user_str = chunks[0]
#   msg = chunks.drop(3).join(' ')
#   user = user_str.split('!', 2).first
#   ctcp = msg[0] == "\001"
#   emote = false
#   if ctcp
#     ctcp_payload = msg.split("\001").last
#     chunks = ctcp_payload.split(' ')
#     if chunks[0].casecmp('ACTION') == 0
#       emote = true
#     end
#   end
#   command = { user: user,
#               user_str: user_str,
#               msg: msg,
#               emote: emote,
#               timestamp: Time.now }
#
#   emit(:query, command)
# end
