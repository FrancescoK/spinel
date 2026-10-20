# The Array a boxed String's split answers is a fresh one nothing else
# holds, so its elements go into a map block that hands them to a method
# whose parameter is a shared String (another caller passes it one), or
# that changes them in place: the block's values carry what was done.
class Label
  attr_reader :group, :leaf_name

  def self.parse(identifier)
    new(identifier.split("/").map { |i| camel_case(i) })
  end

  def self.camel_case(name_part)
    return "XSpec" if name_part == "xspec"
    return name_part unless name_part.match?(/^[a-z]|_[a-z]/)

    name_part.gsub(/^[a-z]|_[a-z]/) { |match| match[-1, 1].upcase }
  end

  def initialize(parts)
    dp = parts[0...-1]
    @group = dp.empty? ? nil : dp.join("/").to_sym
    @leaf_name = parts.last
  end
end

s = +"foo"
t = s
s << "_bar"
p Label.camel_case(t), t
names = ["Group/SectionName", "area/foo_bar", "xspec/x", 1]
p names.map { |n| n.is_a?(String) ? (b = Label.parse(n); [b.group, b.leaf_name]) : n }

v = [" a , b ", 2][0]
p v.split(",").map { |x| x.strip! || x }
p v.split(",").map { |x| x << "!" }
w = v.split(",").map! { |x| x.upcase! ; x }
p w, v
