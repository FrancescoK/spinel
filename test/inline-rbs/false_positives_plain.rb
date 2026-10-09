





class Doc






  def frob(x)
    x
  end


  def hidden(y)
    y
  end

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
p TEXT
p HERE
p WORDS
p RE.source
