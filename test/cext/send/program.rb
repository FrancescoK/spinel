# frozen_string_literal: true
require_relative 'send_sample'
class First
  ANSWER = 42
  def answer = 11
  def add(x) = x + 3
end
class Second < First
  ANSWER = 99
  def answer = 'second'
  def add(x) = x * 2
end
[First.new, Second.new].each do |obj|
  p CextSend.send0(obj)
  p CextSend.send1(obj, 7)
  p CextSend.get(obj)
  p CextSend.set(obj, [1, 'value'])
  GC.start
  p obj.instance_variable_get(:@payload)
  p CextSend.get(obj)
end
p CextSend.constant(First)
p CextSend.constant(Second)
p CextSend.evaluate
p CextSend.collect([1, 2, 3], 10)
p CextSend.collect([1, 2, 3], 10) { |x| x * 2 }

class Emitter
  def emit
    p yield
    p yield(1)
    yield(1, 'two')
  end
end
p CextSend.info(Emitter.new)
class Keeper
  def map(&block)
    @saved = block
    :stored
  end
  def run(x) = @saved.call(x)
end
keeper = Keeper.new
p CextSend.collect(keeper, 'prefix') { |x| x + ' suffix' }
GC.start
p keeper.run(' value')
class Raising
  def answer
    GC.start
    raise ArgumentError, 'from Ruby'
  end
end
begin
  CextSend.send0(Raising.new)
rescue ArgumentError => e
  p e.message
end
begin
  CextSend.collect([1, 2], 3) { raise 'from block' }
rescue RuntimeError => e
  p e.message
end
p CextSend.collect([1, 2, 3], 10) { |x| break x if x == 12; x }
def return_from_callback
  CextSend.collect([1, 2, 3], 10) { |x| return x if x == 12; x }
end
p return_from_callback
p CextSend.send0(First.new)
p CextSend.intern_value('dynamic_symbol')

class Container
  def initialize
    @values = ['Ruby'.dup]
  end
  def container = @values
end
container = Container.new
alias_values = container.container
p CextSend.mutate(container)
p alias_values
p alias_values.equal?(container.container)

class CextNative
  attr_reader :payload
  def initialize
    @ruby = 5
  end
  def ruby = @ruby
end
class NativeChild < CextNative
  def initialize
    super
    @child = 9
  end
  def child = @child
end
native = NativeChild.new
p CextSend.set(native, ['native'.dup])
GC.start
p native.payload
p CextSend.get(native)
p [native.ruby, native.child]
class Third < First; end
p CextSend.constant(Third)
class Nested
  class Inner
    ANSWER = ['nested']
  end
end
p CextSend.constant(Nested::Inner)

class Many
  def many(*args) = args.sum
end
p CextSend.many(Many.new)

class TextContainer
  def initialize = @text = 'Ruby'.dup
  def text = @text
end
text_obj = TextContainer.new
text_alias = text_obj.text
p CextSend.text_mutate(text_obj)
p text_alias
p text_alias.equal?(text_obj.text)

p CextSend.builtin_constant
p CextSend.evaluate_env
class OverriddenConst
  ANSWER = 123
  def self.const_get(name) = :overridden
end
p CextSend.constant(OverriddenConst)

class AttrTextContainer
  attr_reader :text
  def initialize = @text = 'Attr'.dup
end
attr_text_obj = AttrTextContainer.new
attr_text_alias = attr_text_obj.text
p CextSend.text_mutate(attr_text_obj)
p attr_text_alias
p attr_text_alias.equal?(attr_text_obj.text)

class IvarText
  attr_reader :payload
  def initialize = @payload = 'Ivar'.dup
end
ivar_text = IvarText.new
ivar_alias = ivar_text.payload
p CextSend.ivar_text_mutate(ivar_text).length
p ivar_alias.length
p ivar_alias.equal?(ivar_text.payload)

class MutableConsts
  VALUES = ['const'.dup]
  TEXT = 'text'.dup
end
const_array_alias = MutableConsts::VALUES
const_text_alias = MutableConsts::TEXT
p CextSend.constant_mutate(MutableConsts)
p const_array_alias
p const_text_alias
p const_array_alias.equal?(MutableConsts::VALUES)
p const_text_alias.equal?(MutableConsts::TEXT)

begin
  CextSend.constant_mutate(First)
  p :unexpected_constant
rescue NameError => e
  p e.class
end
