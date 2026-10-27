# A String operand given an object converts it through its #to_str, and a
# path operand through its #to_path. The emitter looked the method up again
# from the class the first lookup found it in: when a subclass, reopened,
# aliases the conversion to a method it inherits, that class is the parent,
# which has no such method, the lookup answered none, and the compiler
# crashed. It calls the method the first lookup found.

class Named
  def name = "named"
end

class Labelled < Named
end

class Labelled
  alias to_str name
end

p "the " + Labelled.new
puts "#{Labelled.new.to_str} again"

class Located
  def where = "lib/dir/file.rb"
end

class Source < Located
end

class Source
  alias to_path where
end

p File.basename(Source.new)
