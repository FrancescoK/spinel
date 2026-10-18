# A method returning `nil | Time` types poly (Time has no first-class nullable
# slot), and a caller branch guarded by `a.nil?` or `a` truthiness reads the
# local as a Time inside the non-nil arm (nil_time_return_guard_narrow.rb).
# The value of the method is read through `&&` and `||`: its nil and its Time. The
# answers are the same whether the guarded reads are narrowed or not.
module M
  def self.maybe(s)
    (s && Time.at(0).utc) || nil
  end
end

a = M.maybe("x")
if a.nil?
  puts "branch-nil"
else
  puts "year:" + a.year.to_s
end

b = M.maybe(nil)
if b.nil?
  puts "b-nil"
else
  puts "year:" + b.year.to_s
end

c = M.maybe("x")
puts c.strftime("%Y-%m-%d") if c

d = M.maybe(nil)
puts "d-not-reached" unless d.nil?
unless d.nil?
  puts d.month
end
puts "end"
