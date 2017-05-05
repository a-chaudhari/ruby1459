def ERR_NICKNAMEINUSE(chunks, raw)
  @nickname += '_'
  self.write("NICK #{@nickname}")
  # self.write("USER #{@username} * * :#{@realname}")
end
