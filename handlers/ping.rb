module Ping

  def ping(chunks)
    self.write("PONG #{chunks[1]}")
  end


end
