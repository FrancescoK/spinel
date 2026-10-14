# Under --share-strings, `@header[field] = value.to_s` with value a String
# (or an Integer) stores the String itself: the caller's later change
# shows through the header, and a change through the header shows through
# the caller's name, as webrick's HTTPResponse#[]= has it. The store's
# operands are bound in order to temporaries, the value's declared as the
# shared handle, and it was rendered as the String's bytes (sp_poly_to_s):
# the C did not build.
class Resp
  def initialize
    @header = {}
  end

  def []=(field, value)
    @header[field.downcase] = value.to_s
  end

  def [](field) = @header[field.downcase]
end

resp = Resp.new
loc = +"/x"
resp["Location"] = loc
resp["Content-Length"] = 12
loc << "?q=1"
resp["location"].sub!("/x", "/y")
p resp["Location"], resp["content-length"], loc, loc.equal?(resp["location"])
