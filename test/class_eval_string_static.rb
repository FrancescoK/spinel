# A string class_eval whose text is known at compile time is compiled as
# the code it spells: a heredoc template stamped out per element of a
# literal array (`METHODS.each { |m| class_eval <<-RUBY ... RUBY }`, the
# shape activesupport's BroadcastLogger and core_ext use), and a plain
# literal string. The __FILE__ / __LINE__ arguments are accepted and
# ignored. Only a template whose interpolations are the loop variable
# qualifies; anything else stays a runtime eval, which Spinel refuses.
class Sink
  LEVELS = %w[debug info warn]
  LEVELS.each do |level|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{level}(msg)
        log("#{level.upcase}: " + msg)
      end
      def #{level}? = enabled.include?("#{level}")
    RUBY
  end
  OPS = %i[<< push]
  OPS.each do |op|
    class_eval <<~RUBY, __FILE__, __LINE__ + 1
      def #{op}(line)
        @lines << line
        self
      end
    RUBY
  end
  class_eval <<~'RUBY'
    def count = @lines.size
  RUBY
  class_eval "def first = @lines.first"
  attr_reader :lines, :enabled
  def initialize
    @lines = []
    @enabled = ["info", "warn"]
  end
  # (the pushes name @lines directly: an empty array pushed through its
  # reader is not typed by the pushes, a separate matter)
  def log(text) = @lines << text
end
s = Sink.new
s.info("started")
s.warn("careful")
s.debug("noise") << "raw" 
s.push("more")
p s.lines, s.count, s.first
p s.debug?, s.info?, s.respond_to?(:warn), s.respond_to?(:fatal)
