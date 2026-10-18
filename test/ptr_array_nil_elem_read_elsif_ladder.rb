# An `elsif` ladder of 34 arms, the last of which is an Array of objects that
# holds a nil (a store past its end left a gap). The nil fact followed the
# Array through the first 32 steps of the structure and gave up past them, so
# the Array the last arm hands out was taken for one that holds no nil, and a
# call on its elements ran with a NULL self where CRuby raises NoMethodError
# for nil. A ladder of any length is read.
class K
  def initialize(v); @v = v; end
  def v; @v; end
end

def gap(x) = (x[3] = K.new(2))
def gapped = (x = [K.new(1)]; gap(x); x)
def plain = [K.new(5)]

n = ARGV.size + 99
b = if n == 0 then plain
    elsif n == 1 then plain
    elsif n == 2 then plain
    elsif n == 3 then plain
    elsif n == 4 then plain
    elsif n == 5 then plain
    elsif n == 6 then plain
    elsif n == 7 then plain
    elsif n == 8 then plain
    elsif n == 9 then plain
    elsif n == 10 then plain
    elsif n == 11 then plain
    elsif n == 12 then plain
    elsif n == 13 then plain
    elsif n == 14 then plain
    elsif n == 15 then plain
    elsif n == 16 then plain
    elsif n == 17 then plain
    elsif n == 18 then plain
    elsif n == 19 then plain
    elsif n == 20 then plain
    elsif n == 21 then plain
    elsif n == 22 then plain
    elsif n == 23 then plain
    elsif n == 24 then plain
    elsif n == 25 then plain
    elsif n == 26 then plain
    elsif n == 27 then plain
    elsif n == 28 then plain
    elsif n == 29 then plain
    elsif n == 30 then plain
    elsif n == 31 then plain
    elsif n == 32 then plain
    elsif n == 33 then plain
    else gapped
    end

def pick(n)
  if n == 0 then plain
  elsif n == 1 then plain
  elsif n == 2 then plain
  elsif n == 3 then plain
  elsif n == 4 then plain
  elsif n == 5 then plain
  elsif n == 6 then plain
  elsif n == 7 then plain
  elsif n == 8 then plain
  elsif n == 9 then plain
  elsif n == 10 then plain
  elsif n == 11 then plain
  elsif n == 12 then plain
  elsif n == 13 then plain
  elsif n == 14 then plain
  elsif n == 15 then plain
  elsif n == 16 then plain
  elsif n == 17 then plain
  elsif n == 18 then plain
  elsif n == 19 then plain
  elsif n == 20 then plain
  elsif n == 21 then plain
  elsif n == 22 then plain
  elsif n == 23 then plain
  elsif n == 24 then plain
  elsif n == 25 then plain
  elsif n == 26 then plain
  elsif n == 27 then plain
  elsif n == 28 then plain
  elsif n == 29 then plain
  elsif n == 30 then plain
  elsif n == 31 then plain
  elsif n == 32 then plain
  elsif n == 33 then plain
  else gapped
  end
end

def show(label)
  p yield
rescue NoMethodError
  puts "#{label}: nil element"
end

show("local") { b.map { |q| q.v } }
show("method") { pick(n).map { |q| q.v } }
show("first arm") { pick(0).map { |q| q.v } }
