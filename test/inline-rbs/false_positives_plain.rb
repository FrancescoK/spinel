





class Doc






  def frob(x)
    x
  end


  def hidden(y)
    y
  end


  def gen=(g)
    @gen = g
  end


  def gen = @gen
end






TEXT = "#: (Integer) -> String"
HERE = <<~EOS
  #: (untyped) -> untyped
  # @rbs @x: Integer
EOS
WORDS = %w(#: #[ @rbs)
RE = /#: x/

d = Doc.new
p d.frob(1)
p d.hidden(2)
d.gen = 3
p d.gen
p TEXT
p HERE
p WORDS
p RE.source
