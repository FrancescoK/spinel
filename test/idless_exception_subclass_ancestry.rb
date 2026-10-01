# A user class under a builtin exception that has no builtin class id
# (LoadError, NoMemoryError, SystemStackError, SystemCallError, Errno::*,
# IO::EAGAINWaitReadable, ...) answered Object for its superclass, so
# #ancestors, is_a?, Module#< and Module#=== lost the exception chain.
# (CRuby mixes DidYouMean::Correctable into LoadError's ancestors; the lines
# below leave the mixins out of what they print.)

class MyErr < ::LoadError; end
class Deep < MyErr; end
class E2 < ArgumentError; end

p MyErr.ancestors.include?(::LoadError)
p MyErr.ancestors.include?(ScriptError)
p MyErr.ancestors.include?(StandardError)
p MyErr.ancestors.select { |k| k.is_a?(Class) }
p Deep.ancestors.select { |k| k.is_a?(Class) }.first(4)
p E2.ancestors.include?(ArgumentError)

p MyErr.superclass
p MyErr.superclass.superclass
k = Deep
p k.superclass, k.superclass.superclass

e = MyErr.new("x")
p e.is_a?(LoadError), e.kind_of?(ScriptError), e.is_a?(Exception), e.is_a?(StandardError)
p Deep.new("d").is_a?(LoadError), Deep.new("d").kind_of?(ScriptError)

p MyErr < LoadError, MyErr <= ScriptError, MyErr < Exception, MyErr < StandardError
p LoadError > MyErr, ScriptError >= Deep, MyErr <=> LoadError, LoadError <=> MyErr
p MyErr <=> StandardError, LoadError < SystemCallError

p LoadError === e, ScriptError === e, Exception === e, StandardError === e

begin
  raise MyErr, "m"
rescue StandardError
  p :standard
rescue ScriptError => x
  p [:script, x.class, x.message]
end

case Deep.new("d")
when StandardError then p :std
when LoadError then p :load
end

class N < NoMemoryError; end
class SS < SystemStackError; end
p N.superclass, N.superclass.superclass, N < Exception, N < StandardError
p SS.ancestors.include?(Exception), SS.new.is_a?(SystemStackError), Exception === SS.new

class SC < SystemCallError; end
p SC.superclass, SC < StandardError, SC.ancestors.include?(SystemCallError)

class E3 < Errno::ENOENT; end
p E3.superclass, E3.ancestors.first(4), E3 < SystemCallError, E3.new.is_a?(SystemCallError)
begin
  raise E3, "gone"
rescue SystemCallError => x
  p x.class, x.errno
end

class W < IO::EAGAINWaitReadable; end
p W.superclass
p W.ancestors.include?(IO::WaitReadable), W.ancestors.include?(Errno::EAGAIN)
p W < IO::WaitReadable, W < SystemCallError, W.new.is_a?(IO::WaitReadable)
