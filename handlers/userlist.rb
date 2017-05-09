def RPL_NAMREPLY(chunks, raw)
  chan = @channels[chunks[4]]
  parsed_nicks = {}
  chunks.drop(5).each do |nick|
    output = nick_hash(nick)
    parsed_nicks.merge!(output)
  end
  chan.users.merge!(parsed_nicks)
end

def RPL_ENDOFNAMES(chunks, raw)
  chan = @channels[chunks[3]]
  chan.status = :active
  chan.waiting = false
end
