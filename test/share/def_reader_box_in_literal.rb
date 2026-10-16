# A `def m = @iv` reader of a boxed slot answers the slot's box, as an
# attr_reader does: put in a Hash or Array literal it is the String the
# slot holds, which a change through another name reaches.
class Request
  attr_writer :host
  def host = @host
end
name = +"example"
names = [name]
request = Request.new
request.host = names[0]
opts = { host: request.host }
list = [request.host, 1]
name << ".com"
p opts, list, opts[:host].equal?(request.host)
opts[:host] << "/"
p name, request.host
