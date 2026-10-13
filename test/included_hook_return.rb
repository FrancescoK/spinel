# A `return` in M.included(base) or M.extended(base) leaves the hook only:
# the class body and the program go on after `include M` / `extend M`.
module Tracked
  def self.included(base)
    return if base.name == "Skipped"

    puts "included in #{base}"
  end
end

module Watched
  def self.extended(base)
    [1, 2, 3].each do |i|
      return :early if i == 2

      puts "#{base} sees #{i}"
    end
    puts "not reached"
  end
end

class Kept
  include Tracked
  puts "after include in Kept"
end

class Skipped
  include Tracked
  puts "after include in Skipped"
end

class Seen
  extend Watched
  puts "after extend in Seen"
end

puts "done"
