# A CSV and a CSV::Row include Enumerable, as CRuby's do: through a boxed
# receiver, Enumerable's methods answer for them, and an array still answers.
require "csv"

class Holder
  def initialize(k)
    @c = case k
         when 0 then [1, 2]
         when 1 then CSV.parse("a,b\n1,2\n", headers: true).first
         else CSV.new("x,y\nz,w\n")
         end
  end

  def any = @c.any? { |x| x }
  def enum = @c.is_a?(Enumerable)
end

(0..2).each do |k|
  h = Holder.new(k)
  p [k, h.enum, h.any]
end
p CSV.parse("a,b\n1,2\n", headers: true).first.map { |pair| pair }
p CSV.include?(Enumerable)
p CSV::Row.include?(Enumerable)
