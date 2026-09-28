class Task
  def pausable
    fiber = Fiber.new do
      halted = !catch(:halt) do
        yield
        true
      end
      halted ? :halted : :completed
    end
    fiber.resume
  end
end

items = [Task.new, 1]
p items[0].pausable { :ran }
p items[0].pausable { throw :halt }
p Task.new.pausable { 2 }
