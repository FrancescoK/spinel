# A call dispatched over many receiver classes whose argument is a reader
# called on a boxed receiver. Planning the call's arms plans the argument's
# arms on the way; both went into one plan, and the call's arms were then
# written past the argument's buffer: the compiler aborted.
class Shell
  def say(message = "", color = nil)
    puts "#{self.class}: #{message}"
  end
end
class Shell1 < Shell; end
class Shell2 < Shell; end
class Shell3 < Shell; end
class Shell4 < Shell; end
class Shell5 < Shell; end
class Shell6 < Shell; end
class Shell7 < Shell; end
class Shell8 < Shell; end

module Helpers
  def say(*args)
  end
end

class Command
  attr_accessor :description

  def initialize(description)
    @description = description
  end
end

class HiddenCommand < Command
  def initialize
    super("hidden")
  end
end

def command_help(shell, command)
  shell.say command.description
end

command_help(Shell.new, HiddenCommand.new)
command_help(Shell1.new, Command.new("c1"))
command_help(Shell2.new, Command.new("c2"))
command_help(Shell3.new, Command.new("c3"))
command_help(Shell4.new, Command.new("c4"))
command_help(Shell5.new, Command.new("c5"))
command_help(Shell6.new, Command.new("c6"))
command_help(Shell7.new, Command.new("c7"))
command_help(Shell8.new, Command.new("c8"))
