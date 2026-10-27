# A required file's top level and the methods it defines answer their own
# file and lines, through two levels of require.
puts "#{File.basename(__FILE__)}:#{__LINE__}"
require_relative "frames_a"
puts "#{File.basename(__FILE__)}:#{__LINE__}"
puts FramesB.where
