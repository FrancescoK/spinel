# A method of a Hash, Array, Object or Numeric reopening takes self boxed,
# whatever value it is called on. Calling another of the class's methods
# that takes a &block -- activesupport's Hash#_deep_transform_keys_in_object,
# recursing into itself, under deep_stringify_keys -- passed self cast to
# the class's struct, which a boxed builtin has none of, and the C did not
# compile.
class Hash
  def deep_stringify = deep_keys(&:to_s)
  def deep_symbolize = deep_keys { |k| k.to_sym }
  def deep_keys(&block) = _deep(self, &block)

  private
    def _deep(object, &block)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[yield(key)] = _deep(value, &block)
        end
      when Array
        object.map { |e| _deep(e, &block) }
      else
        object
      end
    end
end

class Array
  def odd_leaves = deep_count(&:odd?)
  def deep_count(&block) = _count(self, &block)

  private
    def _count(object, &block)
      object.is_a?(Array) ? object.sum { |e| _count(e, &block) } : (yield(object) ? 1 : 0)
    end
end

p({ a: { b: [{ c: 1 }] } }.deep_stringify)
p({ "x" => { "y" => 2 } }.deep_symbolize)
p [1, [2, [3, 4]], 5].odd_leaves
