def ERR_NICKNAMEINUSE(chunks, raw)
  old_nick = @nickname
  @nickname += '_'
  self.write("NICK #{@nickname}")
  emit(:self_new_nickname)
  # self.write("USER #{@username} * * :#{@realname}")
end
