# A block with a `next` guard whose value is a conditional tail (#7283): the
# tail's arms computed the value and dropped it, so filter_map kept nothing.
# And select's `next false` beside an Integer tail read truthy.
def mark_firing(k) = k != "c"
def notify(_m) = true

r1 = ["a"].filter_map do |k|
  next unless true
  k if true
end
p r1

r2 = ["a"].filter_map do |k|
  next if false
  k if true
end
p r2

r3 = ["a", "b", "c"].filter_map do |key|
  next unless mark_firing(key)
  sent = notify(key)
  puts "side effect" unless sent
  key if sent
end
p r3

p [1, 2, 3, 4].filter_map { |x| next if x == 2; x > 1 ? x * 10 : nil }
p [1, 2, 3, 4].filter_map { |x| next if x == 2; if x.odd? then x else nil end }
p [1, 2, 3, 4].filter_map { |x| next if x == 2; x unless x == 4 }
p [1, 2, 3, 4].filter_map { |x| next if x == 1; case x when 3 then nil else x * 2 end }
p [1, 2, 3, 4].filter_map { |x| next if x == 1; if x == 3 then next 99 else x end }
p [1, 2, 3].select { |x| next false if x == 2; x if x > 0 }
p [1, 2, 3].reject { |x| next true if x == 2; x if x > 2 }
p [1, 2, 3].select { |x| next false if x == 2; true }
