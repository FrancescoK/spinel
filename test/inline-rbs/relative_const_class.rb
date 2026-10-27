# A qualified type name relative to the enclosing module
# (`ControlMessage::CType` inside `module Stage`) names a class made by
# `Data.define`, as `Stage::ControlMessage::CType` does: Ruby's lexical
# lookup and RBS name resolution both find it (#10370).
module Stage
  module ControlMessage
    CType = Data.define(:message)
    OK = CType.new(message: :ok)
  end

  class X
    #: (untyped) -> untyped
    def echo(v) = v

    #: () -> ControlMessage::CType
    def a = ControlMessage::OK

    #: () -> Stage::ControlMessage::CType
    def b = ControlMessage::OK
  end
end

x = Stage::X.new
p x.a, x.b.message, x.echo(1)
