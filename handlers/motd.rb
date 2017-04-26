def RPL_MOTD(chunks, raw)
  @server_motd += chunks.drop(4).join(' ') + "\n"
end

def RPL_WELCOME(chunks, raw)
  @status = :connected
  emit(:registered)
end
