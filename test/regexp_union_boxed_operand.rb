# A boxed operand of Regexp.union or Regexp.escape is checked as CRuby's
# StringValue checks it: a String (also a shared one, or an object answering
# #to_str) is escaped, a Regexp joins a union by its (?on-off:src) form, a
# Symbol is escape's by name, and anything else raises TypeError. Reading the
# operand through #to_s turned 1 into the pattern "1" and nil into "". A lone
# boxed argument is told apart at run time: an Array is the union of its
# elements, each checked the same way, a lone Regexp is the answer itself and
# any other lone operand is quoted as escape takes it.
def try
  p yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

class Pat
  def to_str = "p.q"
end

def pick(k)
  case k
  when 0 then 1
  when 1 then nil
  when 2 then :"s.t"
  when 3 then "a.b"
  when 4 then /x.y/i
  when 5 then Pat.new
  when 6 then 1.5
  when 7 then true
  when 8 then ["a.b", /x/m]
  when 9 then [/r/i]
  when 10 then []
  when 11 then ["a", 1]
  else [["a"]]
  end
end

(0..12).each do |k|
  v = pick(k)
  try { Regexp.union(v) }
  try { Regexp.union([v]) }
  try { Regexp.union(*[v]) }
  try { Regexp.union(v, "c") }
  try { Regexp.union(["c", v]) }
  try { Regexp.escape(v) }
end

s = +"h."
s << "k"
s = 2 if ARGV.size > 5
try { Regexp.union(s, "c") }
try { Regexp.union(s) }
