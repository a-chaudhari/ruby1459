def RPL_NAMREPLY(chunks, raw)
  chan = @channels[chunks[4]]
  chan.users.merge(chunks.drop(5))
end

def RPL_ENDOFNAMES(chunks, raw)
  chan = @channels[chunks[3]]
  chan.status = :active
  chan.waiting = false
end
