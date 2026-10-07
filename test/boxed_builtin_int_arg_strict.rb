VALS = ["hello", [1, 2, 3, 4], 1.55, 1234, nil]
ARGS = [1, 1.9, nil, "1", {a: 1}, :s, [1]]

def try(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue TypeError, ArgumentError, IndexError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

s = VALS[0]
a = VALS[1]
f = VALS[2]
i = VALS[3]
ARGS.each do |x|
  try("index #{x.inspect}") { s.index("l", x) }
  try("rindex #{x.inspect}") { s.rindex("l", x) }
  try("slice #{x.inspect}") { a.slice(1, x) }
  try("first #{x.inspect}") { a.first(x) }
  try("last #{x.inspect}") { a.last(x) }
  try("round #{x.inspect}") { f.round(x) }
  try("digits #{x.inspect}") { i.digits(x.is_a?(Integer) ? x + 9 : x) }
  try("at #{x.inspect}") { a.at(x) }
  try("fetch #{x.inspect}") { a.fetch(x) }
  try("take #{x.inspect}") { a.take(x) }
  try("drop #{x.inspect}") { a.drop(x) }
  try("rotate #{x.inspect}") { a.rotate(x) }
  try("center #{x.inspect}") { s.center(x.is_a?(Integer) ? x + 8 : x) }
  try("ljust #{x.inspect}") { s.ljust(x.is_a?(Integer) ? x + 8 : x) }
end
