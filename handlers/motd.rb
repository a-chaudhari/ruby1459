module Motd

  def RPL_MOTD(chunks)
    @server_motd += chunks.drop(4).join(' ') + "\n"
  end
  
end
