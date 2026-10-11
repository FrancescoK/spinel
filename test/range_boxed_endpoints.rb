# A Range whose ends are only known at run time -- elements of a mixed
# Array or Hash, a method that answers more than one kind -- takes its kind
# from the values, as CRuby's does. It was always an Integer Range, so a
# String end read as a number: `arr[1]..arr[2]` over ["b", "e"] printed
# 0..0, walked [0] and found nothing, and "1".."3" was 1..3. Ends that
# cannot be compared raise CRuby's ArgumentError, a String beside a boxed
# end is checked the same way, and a boxed String Range answers include?.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

arr = [1, "b", "e", 2.5, nil, 5, "1", "3"]
t("p") { arr[1]..arr[2] }
t("excl") { arr[1]...arr[2] }
t("endless") { (arr[1]..) }
t("beginless") { (..arr[2]) }
t("nil begin") { arr[4]..arr[2] }
t("to_a") { (arr[1]..arr[2]).to_a }
t("each") { x = []; (arr[1]..arr[2]).each { |v| x << v }; x }
t("map") { (arr[1]..arr[2]).map { |v| v * 2 } }
t("include?") { (arr[1]..arr[2]).include?("c") }
t("include? no") { (arr[1]..arr[2]).include?("z") }
t("member? int") { (arr[1]..arr[2]).member?(3) }
t("endless include?") { (arr[1]..).include?("c") }
t("cover?") { (arr[1]..arr[2]).cover?("cc") }
t("===") { (arr[1]..arr[2]) === "d" }
t("ends") { r = arr[1]..arr[2]; [r.first, r.last, r.begin, r.end, r.min, r.max] }
t("count") { (arr[1]..arr[2]).count }
t("to_s") { (arr[1]...arr[2]).to_s }
t("==") { r = arr[1]..arr[2]; r == ("b".."e") }
t("numeric strings") { [arr[6]..arr[7], (arr[6]..arr[7]).to_a] }
t("sum strings") { (arr[1]..arr[2]).sum("") }

# Integer and Float values keep their Range kinds
t("ints") { r = arr[0]..arr[5]; [r, r.to_a, r.sum, r.include?(3), r.size] }
t("ints each") { x = []; (arr[0]..arr[5]).each { |v| x << v + 1 }; x }
t("ints step") { (arr[0]..arr[5]).step(2).to_a }
t("int float") { r = arr[0]..arr[3]; [r.begin, r.end, r.to_a, r.include?(2.2)] }
t("float begin") { r = arr[3]..arr[5]; [r.begin, r.end, r.include?(4.5), r.include?(2)] }
t("float endless") { r = (arr[3]..); [r.begin, r.end, r.include?(1e9)] }
t("float each") { (arr[3]..arr[5]).each { } }
t("box int float end") { (arr[0]..3.5).to_a }
t("box int end") { (arr[0]..3).to_a }
t("box nil int end") { r = arr[4]..3; [r.include?(-5), r.end] }
t("nil nil") { arr[4]..arr[4] }
t("endless each") { x = []; (arr[0]..arr[4]).each { |v| x << v; break if x.size > 2 }; x }

# ends that cannot be compared
t("int str") { arr[0]..arr[1] }
t("str int") { arr[1]..arr[0] }
t("lit str int") { "a"..arr[0] }
t("lit int str") { 1..arr[1] }
t("lit float str") { 1.5..arr[1] }

# a String beside a boxed end
t("str box") { r = "a"..arr[2]; [r, r.to_a] }
t("box str") { r = arr[1].."d"; [r, r.to_a, r.include?("c")] }
t("str nil") { "c"..arr[4] }

for v in arr[1]..arr[2]
  print v
end
puts
case "c"
when arr[1]..arr[2] then puts "in"
else puts "out"
end

# other holders and endpoint expressions
h = {lo: "x", hi: "z", n: 1}
t("hash") { (h[:lo]..h[:hi]).to_a }
def lo(a) = a[1]
def hi(a) = a[2]
t("methods") { (lo(arr)..hi(arr)).to_a }
class C
  def initialize(a) = (@a = a)
  def r = (@a[1]..@a[2])
end
t("ivar") { C.new(arr).r.to_a }
def via_param(a) = (a[1]..a[2]).each.to_a
t("param") { via_param(arr) }
A = [1, "p", "r"]
t("const") { (A[1]..A[2]).to_a }
t("first last") { A.first..A.last }
t("first last str") { (A[1]..A.last).to_a }
def keep(r) = r
t("passed") { keep(arr[1]..arr[2]).to_a }
t("in array") { [arr[1]..arr[2], 1..2] }
