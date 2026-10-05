# A call on a method's nilable result, standing as a statement (its value
# discarded), declares the guarded temp ahead of what the statement itself
# hoists: the C named the temp before it existed and did not build (#7343).
class Widget
  def initialize(n) = @n = n
  def touch
    puts "touched #{@n}"
  end
  def poke(a, b)
    puts "poke #{@n} #{a} #{b}"
  end
end

class Report
  def initialize(present)
    @present = present
  end

  def widget
    return nil unless @present
    Widget.new(1)
  end

  def notify
    widget.touch
    puts "after"
  end

  def in_branch(flag)
    if flag
      widget.touch
    else
      widget.poke(1, [2].first)
    end
    puts "branch done"
  end

  def in_loop
    2.times do |i|
      widget.poke(i, i.to_s)
    end
    puts "loop done"
  end
end

def t(label)
  yield
rescue NoMethodError => e
  puts "#{label}: NoMethodError: #{e.message}"
end

t("notify") { Report.new(true).notify }
t("notify") { Report.new(false).notify }
t("branch") { Report.new(true).in_branch(true) }
t("branch") { Report.new(true).in_branch(false) }
t("branch") { Report.new(false).in_branch(false) }
t("loop") { Report.new(true).in_loop }
t("loop") { Report.new(false).in_loop }

r = Report.new(true)
r.widget.touch
r = Report.new(false)
begin
  r.widget.touch
rescue NoMethodError => e
  puts "top: NoMethodError: #{e.message}"
end
