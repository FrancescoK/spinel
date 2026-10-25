class Request
  def request_method = "GET"
end

class Thread
  def self.current = Request.new
end

class Fiber
  def self.current = Request.new
end

p Thread.current.request_method
p Fiber.current.request_method

thread_class = Thread
fiber_class = Fiber
p thread_class.current.request_method
p fiber_class.current.request_method
