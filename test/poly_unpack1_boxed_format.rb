# A boxed receiver's unpack1 through a dynamic send whose format argument
# is boxed too (a program class owns the name, so the String case is the
# dispatch's tag pre-arm): the boxed format went straight into
# sp_str_unpack's const char * slot, and the C did not build.
class Model
  def unpack1(fmt) = "model #{fmt}"
  def url_for(*args) = "url #{args.inspect}"
end
def call_it(recipient, method, *args, options)
  if options.empty?
    recipient.public_send(method, *args)
  else
    recipient.public_send(method, *args, options)
  end
end
m = ARGV.empty? ? Model.new : "abc"
p call_it(m, :url_for, 1, 2, { x: 1 })
p call_it(m, :unpack1, { y: 2 })
p call_it("abc", :unpack1, "a*")
p call_it("abc", :upcase, {})
