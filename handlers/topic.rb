def RPL_TOPIC(chunks, raw)
  topic = chunks.drop(4).join(' ')
  chan_str = chunks[3]
  @channels[chan_str].topic = topic
end

def TOPIC(chunks, raw)
  topic = chunks.drop(3).join(' ')
  chan_str = chunks[2]
  @channels[chan_str].topic = topic
end
