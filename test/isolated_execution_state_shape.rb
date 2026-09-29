# activesupport's IsolatedExecutionState: an attribute on every thread and
# fiber, a scope that is the Thread or Fiber class itself, and the state
# read and set through `@scope.current` -- `current` on a class value
# holding a builtin class, then the accessor, then `||=` on it.

module State
  Thread.attr_accessor :execution_state
  Fiber.attr_accessor :execution_state

  class << self
    attr_reader :isolation_level, :scope

    def isolation_level=(level)
      return if level == @isolation_level
      unless %i(thread fiber).include?(level)
        raise ArgumentError, "isolation_level must be `:thread` or `:fiber`, got: `#{level.inspect}`"
      end
      clear if @isolation_level
      @scope =
        case level
        when :thread; Thread
        when :fiber; Fiber
        end
      @isolation_level = level
    end

    def [](key)
      if state = @scope.current.execution_state
        state[key]
      end
    end

    def []=(key, value)
      state = (@scope.current.execution_state ||= {})
      state[key] = value
    end

    def key?(key)
      @scope.current.execution_state&.key?(key)
    end

    def delete(key)
      @scope.current.execution_state&.delete(key)
    end

    def clear
      @scope.current.execution_state&.clear
    end

    def context
      scope.current
    end
  end

  self.isolation_level = :thread
end

p State.isolation_level, State[:a]
State[:a] = 1
State[:b] = "two"
p State[:a], State[:b], State.key?(:a), State.key?(:z)
p State.context == Thread.current
t = Thread.new { State[:a] = :child; State[:a] }
p t.value, State[:a]
State.delete(:a)
p State[:a], State.key?(:b)

State.isolation_level = :fiber
p State.isolation_level, State[:b]
State[:f] = :fib
p State[:f], State.context == Fiber.current
f = Fiber.new { State[:f] = :inner; State[:f] }
p f.resume, State[:f]
begin
  State.isolation_level = :process
rescue ArgumentError => e
  puts e.message
end
