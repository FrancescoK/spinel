# A Proc passed to a method that takes a block, where a block in that method
# captures the Proc's parameter, binds into the parameter's cell.

def on_signal(name, action)
  later = proc { action.call(name) }
  yield
  later.call
end

handler = lambda { |n| puts "handled #{n}" }
on_signal("INFO", handler) { puts "running" }

class Runner
  def self.run_suite
    @handler = lambda { puts "info for #{self}" }
    with_handler { puts "running #{name}" }
  end

  def self.with_handler(&block)
    on_signal "INFO", @handler, &block
  end

  def self.on_signal(name, action)
    later = proc { action.call }
    yield
    later.call
  end
end

class SubRunner < Runner; end
Runner.run_suite
SubRunner.run_suite

def twice(f)
  g = -> { f.call + 1 }
  yield g.call
end
twice(-> { 41 }) { |v| p v }
twice(nil.then { -> { 1 } }) { |v| p v }
