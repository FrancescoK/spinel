# Exception#exception given the receiver itself answers the receiver; given
# another exception, a copy whose message is that exception's text.
e = RuntimeError.new("a")
p e.exception(e).equal?(e)
p e == e.exception(e)
x = e.exception(ArgumentError.new("b"))
p x.class, x.message, x.equal?(e)
p e.exception("z").message, e.message
