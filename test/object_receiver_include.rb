# `Object.include M` as a statement of the program mixes M into Object as
# `class Object; include M; end` does: its constants and methods reach every
# object. It was refused before, and a NoMethodError at run time before that.
module GuardMixin
  MixedConst = :mixed
  def guarded? = true
end
Object.include GuardMixin
puts "missing" unless defined?(MixedConst)
p MixedConst, 1.guarded?, "s".guarded?
