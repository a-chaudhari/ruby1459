def ping(chunks, raw)
  self.write("PONG :#{chunks.drop(1).join(" ")}")
end
