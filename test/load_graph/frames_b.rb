module FramesB
  def self.where
    "#{File.basename(__FILE__)}:#{__LINE__} in #{__method__}"
  end
end


puts "#{File.basename(__FILE__)}:#{__LINE__}"
puts FramesB.where
