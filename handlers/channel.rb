def RPL_TOPIC(chunks)
  p chunks
end

def RPL_NAMREPLY(chunks)
  # debugger
  chan = @channels[chunks[4]]
  chunks[5][0]='' #strips leading : from first nick
  chan.users += chunks.drop(5)
end

def RPL_ENDOFNAMES(chunks)
  chan = @channels[chunks[3]]
  p chan.users
  chan.status = :active
  chan.waiting = false
end
