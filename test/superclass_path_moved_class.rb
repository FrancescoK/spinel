# A class moved under another module's path before a header names it there:
# `AS::CoreExt::Err = remove_const(:Err)` makes AS::CoreExt::Err the class,
# so `class Sub < AS::CoreExt::Err` subclasses it and a rescue by that path
# catches it. The pass that drops the self-aliasing write before the walk
# leaves the load record unsure of the name, not sure that it names nothing.

module AS
  module CoreExt
  end
end

module Host
  class Err < StandardError
    def hint = "moved"
  end
  AS::CoreExt::Err = remove_const(:Err)
end

class Sub < AS::CoreExt::Err
end
p Sub.superclass == AS::CoreExt::Err
p Sub.ancestors.include?(StandardError)

begin
  raise Sub, "sub"
rescue AS::CoreExt::Err => e
  p e.message, e.hint
end
