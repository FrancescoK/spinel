# A `<=>` that always answers nil is still called by Comparable's ==, <,
# between? and by sort: CRuby runs it and reads nil as "not comparable", so
# == is false and the others raise.

class Never
  include Comparable
  attr_reader :log
  def initialize(log) = @log = log
  def <=>(o)
    @log << :cmp
    nil
  end
end

log = []
a = Never.new(log)
b = Never.new(log)
p a == b
p a != b
p a == a
p log

log.clear
begin
  p a < b
rescue ArgumentError => e
  puts e.message
end
p log

log.clear
begin
  p [a, b].sort.size
rescue ArgumentError => e
  puts e.message
end
p log

log.clear
begin
  p a.between?(a, b)
rescue ArgumentError => e
  puts e.message
end
p log
