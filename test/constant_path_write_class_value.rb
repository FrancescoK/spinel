# A class moved under another module's path -- activesupport's
# core_ext/enumerable.rb keeps Enumerable free of constants with
#   ActiveSupport::EnumerableCoreExt::SoleItemExpectedError = remove_const(:SoleItemExpectedError)
# -- is a constant path write of a class value: the qualified name then
# raises and rescues the class, and a scalar path write beside it still does.

module AS
  module CoreExt
  end
end

module Host
  class Err < StandardError
    def hint = "moved"
  end
  AS::CoreExt::Err = remove_const(:Err)
  AS::CoreExt::LIMIT = 3
  def self.boom = raise(AS::CoreExt::Err, "boom")
  def self.limit = AS::CoreExt::LIMIT
end

begin
  Host.boom
rescue AS::CoreExt::Err => e
  p e.message, e.hint, e.class == AS::CoreExt::Err
end
p Host.limit
p AS::CoreExt::Err.new("direct").message
p AS::CoreExt::Err.ancestors.include?(StandardError)
