# A Float Range read out of a slot that holds other kinds too: its value
# methods answer as the typed Float Range's do. #begin / #end / #min / #max
# were NoMethodError, #size / #count / #sum answered 0, #cover? false,
# #frozen? false, and #first / #last of an open one the infinity sentinel.
# (Its #count when open is Infinity, which the boxed Integer #count cannot
# hold: it raises rather than answers, and is left out here. #step and
# #bsearch with a block are in range_boxed_step_bsearch.rb.)

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end
src = [(1.5..3.0), (...2.5), (1.5..), 7, (..3)]
r0 = src[4]
t("int beginless each") { r0.each { |i| }; nil }
t("int frozen") { r0.frozen? }
t("int begin") { r0.begin }
t("int end") { r0.end }
src.each do |x|
  next if x.is_a?(Integer) || x == r0
  t("#{x} inspect") { x }
  t("begin") { x.begin }
  t("end") { x.end }
  t("first") { x.first }
  t("last") { x.last }
  t("min") { x.min }
  t("max") { x.max }
  t("size") { x.size }
  t("count") { x.count } unless x.begin.nil? || x.end.nil?
  t("include") { x.include?(2.0) }
  t("cover") { x.cover?(2.0) }
  t("===") { x === 2.0 }
  t("exclude_end") { x.exclude_end? }
  t("to_s") { x.to_s }
  t("to_a") { x.to_a }
  t("each") { x.each { |i| }; nil }
  t("sum") { x.sum }
  t("==") { x == (1.5..3.0) }
  t("eql") { x.eql?(1.5..3.0) }
  t("class") { x.class }
  t("frozen") { x.frozen? }
  t("dup") { x.dup }
end
