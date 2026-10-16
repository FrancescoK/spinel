# A reader whose ivar widened past a String answers its box: an identity
# test that demands the handle takes the box as it is (#9258)
class Request
  attr_writer :host
  def host = @host
end
name = +"example"
names = [name]
request = Request.new
request.host = names[0]
name << ".com"
p request.host.equal?(request.host)
x = request.host
p x.equal?(request.host), x
