# A call no value reaches (the blocking server's handle, when the program
# only ever starts the threaded one) still binds every method of its
# name: dropping it left Front#dispatch's parameters bound by nothing, so
# untyped, and the untyped `res` it handed on widened the live App's `res`
# to a box, whose `status=` then dispatched to every class with a `status=`
# and did not compile against Widget's nullable Integer (#9514).
class Request
  attr_accessor :path
end

class Response
  attr_accessor :status
end

class Widget
  def status=(value)
    @status = value
  end
  def status = @status
end

class App
  def dispatch(req, res)
    res.status = req.path == "/missing" ? 404 : 200
    [req.path, res.status]
  end
end
APP = App.new

class Front
  def dispatch(req, res) = APP.dispatch(req, res)
end

class Server
  def initialize(app) = @app = app
  def handle
    req = Request.new
    req.path = "/"
    @app.dispatch(req, Response.new)
  end
end

class Threaded
  def initialize(app) = @app = app
  def run(path)
    req = Request.new
    req.path = path
    APP.dispatch(req, Response.new)
  end
end

w = Widget.new
w.status = nil
w.status = 1
p Threaded.new(Front.new).run("/")
p Threaded.new(Front.new).run("/missing")
p w.status
