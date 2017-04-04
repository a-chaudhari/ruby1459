def RPL_MOTD(chunks)
  @server_motd += chunks.drop(4).join(' ') + "\n"
end

def RPL_WELCOME(chunks)
  @status = :connected
  emit(:registered)
end
