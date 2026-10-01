# The file argument is a call that has to run: a graft would drop it, so the
# class_eval is not grafted.
class Sink
  def self.where = (puts "where"; "sink.rb")
  NAMES = %w[info]
  NAMES.each do |n|
    class_eval "def #{n} = 1", where
  end
end
p Sink.new.info
