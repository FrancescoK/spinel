# A wrong argument count on a boxed receiver raises CRuby's ArgumentError
# with the range of the receiver's own class, for every builtin class a box
# carries (Rational, Complex, Time, a Float or String Range, Regexp,
# MatchData, Enumerator, Proc, Method, File, Queue, Mutex), and for a
# class that rejects the count while another class with the name takes
# it. A class without the method still raises NoMethodError.

def show(tag)
  p yield
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def t(k)
  show("rational") { [Rational(3, 4), :x][k].remainder }
  show("rational nilable") { (k == 0 ? Rational(3, 4) : nil).between?(1) }
  show("complex") { [Complex(1, 2), :x][k].rectangular(1) }
  show("time") { [Time.at(0).utc, :x][k].tv_sec(1) }
  show("float range") { [(0.5..2.5), :x][k].cover? }
  show("string range") { [("a".."e"), :x][k].include? }
  show("regexp") { [/a/, :x][k].match? }
  show("matchdata") { ["ab".match(/a/), :x][k].pre_match(1) }
  show("enumerator") { [[1, 2].each, :x][k].size(1) }
  show("proc") { [proc { 1 }, :x][k].arity(1) }
  show("method") { [1.method(:+), :x][k].owner(1) }
  show("file") { [File.open(File::NULL), :x][k].fileno(1) }
  show("queue") { [Thread::Queue.new, :x][k].empty?(1) }
  show("mutex") { [Thread::Mutex.new, :x][k].locked?(1) }
  show("queue push") { [Thread::Queue.new, :x][k].push }
  show("sized queue push") { [Thread::SizedQueue.new(2), :x][k].push }
  show("string to_s") { ["ab", 7][k].to_s(2) }
  show("integer to_s") { [7, "ab"][k].to_s(2) }
  show("string getbyte") { ["ab", 7][k].getbyte }
  show("array to_a") { [[1], 7][k].to_a(1) }
  show("symbol nomethod") { [:x, 7][k].remainder }
end
t(ARGV.size)
