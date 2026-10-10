# spinel: gc-stress
# spinel: share
class RootTag
  def initialize(s) = (@s = s)
  def to_s = @s
end
def churn
  GC.start
  64.times.map { |k| "j#{k}" }.size
  ""
end
def pick(i)
  "#{churn}#{(case i
              in 1
                x = i * 3
                RootTag.new("c#{x}")
              else
                RootTag.new("o#{i}")
              end).to_s}"
end
def pick_if(i)
  "#{churn}#{(if i > 0
                x = i * 2
                RootTag.new("v#{x}")
              else
                RootTag.new("n#{i}")
              end).to_s}"
end
3.times { |i| puts pick(i); puts pick_if(i) }

def pick_when(i)
  "#{churn}#{(case i
              when 1
                x = i * 3
                RootTag.new("w#{x}")
              else
                RootTag.new("e#{i}")
              end).to_s}"
end
def make_tag(i) = RootTag.new("m#{i}")
def range_in(i)
  "#{churn}#{(case i
              in 1
                x = i * 3
                ("a#{x}".."z#{x}")
              else
                ("b#{i}".."y#{i}")
              end).first}"
end
3.times do |i|
  puts pick_when(i)
  puts "#{churn}#{make_tag(i).to_s}"
  puts range_in(i)
end
