require_relative 'irc'

irc = Irc.new

irc.open
irc.read

while true
  cmd = gets.chomp
  irc.write(cmd)
end
