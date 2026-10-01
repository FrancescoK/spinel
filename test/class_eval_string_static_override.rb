# A class_eval the program defines itself is the one the call reaches: the
# text is handed to it, not grafted as code.
module Recorder
  def class_eval(src) = (@srcs ||= []) << src
  def srcs = @srcs
end
class Taped
  extend Recorder
  NAMES = %w[info warn]
  NAMES.each do |n|
    class_eval "def #{n} = 1"
  end
end
p Taped.new.respond_to?(:info), Taped.srcs
