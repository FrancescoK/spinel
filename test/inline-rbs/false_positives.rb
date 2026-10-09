# frozen_string_literal: true
#[notes]
# Comments that look like inline RBS and are not. None of them may be read as
# a type: the C must equal the C of false_positives_plain.rb, which is this
# file with every comment blanked out, line for line.

class Doc #:nodoc:
  # :nodoc:
  #:yields: value
  #:call-seq: frob(x) -> y
  # Returns #: the value, see #[] too
  #   @rbs is mentioned here in prose
  # x = frob(1) #: Integer
  def frob(x) # @rbs is mentioned here
    x
  end

  #:stopdoc:
  def hidden(y)
    y
  end
  #:startdoc:
end

=begin
#: (Integer) -> String
# @rbs x: Integer
=end

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
