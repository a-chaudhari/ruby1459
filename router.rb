require_relative 'commands'

class Router

  def initialize(server)
    # p "test"
    @s = server
  end

  def route(command, payload)
    # p "router"
    # p payload
    # p command
    com = COMMANDS[command]
    p com
  end

  def ping(payload)
    debugger
  end







end
