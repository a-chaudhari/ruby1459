def ERR_NICKNAMEINUSE(chunks, raw)
  @nickname += '_'
  self.write("NICK #{@nickname}")
  emit(:self_new_nickname)
end
