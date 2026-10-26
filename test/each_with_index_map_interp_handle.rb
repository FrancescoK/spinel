# each_with_index.map collecting an interpolated String held in a local:
# the block's value slot is the handle and takes the String as one.
STAGES = %w[events emulate audio].freeze

class Report
  def initialize = @spent = Array.new(STAGES.size, 0.5)

  def show
    stages = STAGES.each_with_index.map { |name, stage| "#{name} #{(@spent[stage] * 20).round(2)}" }
    puts stages.join(" ")
    stages
  end
end

names = %w[a b c]
labels = names.each_with_index.map { |name, i| "#{name}#{i}" }
puts labels.join(",")
labels << "d"
p labels
p names.each_with_index.select { |name, i| "#{name}#{i}" }.size
p names.each_with_index.count { |name, i| "#{name}#{i}" }
r = Report.new.show
r[0] << "!"
p r
