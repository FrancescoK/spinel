# all?, any?, none? and one? given a splatted Array take its elements as
# their arguments: none is the no-pattern form, one is the pattern. The Array
# itself was taken as the pattern, so `any?(*[])` asked `[] === e`.
# activesupport's ArrayInquirer#any?(*candidates) hands an empty one to
# Array#any? through a bare super.
e = []
o = [Integer]
x = [1, nil, 2]
p x.any?(*e), x.all?(*e), x.none?(*e), x.one?(*e)
p x.any?(*o), x.all?(*o), x.none?(*o), x.one?(*o)

class Tags < Array
  def any?(*candidates)
    if candidates.none?
      super
    else
      candidates.any? { |c| include?(c.to_sym) || include?(c.to_s) }
    end
  end
end
t = Tags.new([:mobile, "web"])
p t.any?, t.any?(:mobile, :desk), t.any?(:desk), Tags.new.any?
