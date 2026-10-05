# A call on a user method's nil result (a builtin find that finds nothing, a
# nil it writes or returns, a module accessor of an ivar nothing sets)
# raises NoMethodError as CRuby does, in expression and statement form.
$stdout.sync = true
class Box
  def initialize(v) = @v = v
  def v = @v
  def hello = "hello"
end
class Repo
  def initialize = @items = [Box.new(1), Box.new(2)]
  def find(i) = @items.find { |b| b.v == i }
  def pick(i) = i == 1 ? Box.new(1) : nil
  def early(i)
    return nil if i > 5
    Box.new(i)
  end
end
module M
  def self.box = @box
end
r = Repo.new
[-> { r.find(1).v }, -> { r.find(9).v }, -> { r.find(9).hello }, -> { r.pick(2).v },
 -> { r.early(7).v }, -> { r.early(1).v }, -> { M.box.hello }, -> { M.box.v }].each do |f|
  begin
    p f.call
  rescue NoMethodError => e
    p e.message
  end
end
begin
  r.find(9).hello
  puts "not reached"
rescue NoMethodError => e
  puts "stmt: #{e.message}"
end
x = r.find(2)
p x.v
