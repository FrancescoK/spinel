# A receiverless exec/spawn reaches the program's own method only where self
# has it (the bubbletea gem's `Bubbletea.exec(callable)` is its module's);
# elsewhere it is Kernel's, as in CRuby.
module Tea
  def self.exec(callable) = "own exec #{callable.call}"
  def self.spawn(x) = "own spawn #{x}"
  def self.run = [exec(-> { 1 }), spawn(2)]
end

class Shell
  def start
    pid = spawn("true")
    Process.wait(pid)
    $?.success?
  end

  # never called: Kernel#exec here would replace the process
  def replace = exec("true")
end

p Tea.run
p Shell.new.start
