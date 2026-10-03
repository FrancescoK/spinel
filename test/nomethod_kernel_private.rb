# A Kernel method sent to an explicit receiver that does not define it is
# "private method 'select' called for ..." (Kernel defines it private), not
# "undefined method": select, puts, format, sleep, rand, open, and the rest of
# Kernel.private_instance_methods. A name Kernel does not define stays
# "undefined method". Typed receivers and boxed ones.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue NoMethodError => e
  puts "#{s}: #{e.message}"
end

class Nope; end
t("int select") { 5.select { |x| x } }
t("str select") { "s".select { |x| x } }
t("sym select") { :s.select { |x| x } }
t("nil select") { nil.select { |x| x } }
t("obj select") { Nope.new.select { |x| x } }
t("float select") { 2.5.select { |x| x } }
t("int puts") { 5.puts }
t("nil puts") { nil.puts "x" }
t("obj format") { Nope.new.format("x") }
t("obj sleep") { Nope.new.sleep }
t("obj rand") { Nope.new.rand }
t("obj open") { Nope.new.open }
t("obj undefined") { Nope.new.frobnicate }
t("int undefined") { 5.frobnicate }
t("nil filter") { nil.filter { |x| x } }

vals = [nil, 5, :sym, "str", Nope.new, 2.5]
vals.each do |v|
  t("boxed select") { v.select { |x| x } }
  t("boxed select noblk") { v.select }
  t("boxed filter") { v.filter { |x| x } }
  t("boxed puts") { v.puts }
end
