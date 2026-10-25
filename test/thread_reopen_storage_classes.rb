class Request
  attr_accessor :request_method
  def initialize = @request_method = "GET"
end

class Response
  def status = 201
end

class Thread
  def tag = :thread
end

class Fiber
  def tag = :fiber
end

module Current
  def self.request = Thread.current[:request]
  def self.request=(value)
    Thread.current[:request] = value
  end
end

Current.request = Request.new
GC.start
p Current.request.request_method

Thread.current[:response] = Response.new
p Thread.current[:response].status

thread = Thread.current
thread[:requests] = [Request.new]
GC.start
p thread[:requests][0].request_method

thread.thread_variable_set(:response, Response.new)
p thread.thread_variable_get(:response).status

boxed = [Thread.current, 0][0]
boxed[:request] = Request.new
p boxed[:request].request_method

Fiber[:request] = Request.new
GC.start
p Fiber[:request].request_method

p Fiber.current.storage[:request].request_method

thread_class = Thread
thread_class.current[:request] = Request.new
p thread_class.current[:request].request_method

fiber_class = Fiber
p fiber_class.current.storage[:request].request_method

p [Thread.current.tag, Fiber.current.tag]
