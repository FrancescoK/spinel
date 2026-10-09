# Captured builtin singleton dispatch is refused until it can keep its target.
# spinel: reject-builtin-class: Time.at: rebinding a builtin singleton method captured by an alias is not supported
class Time
  class << self
    def at_with_coercion(value) = at_without_coercion(value.to_i)
    alias_method :at_without_coercion, :at
    alias_method :at, :at_with_coercion
  end
end
p Time.at("7").to_i
