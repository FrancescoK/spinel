class U
  def up = dir.upcase
  def subs = dir.sub("a", "b")
  def splits = dir.split(",")
  def size = dir.size
  def starts = dir.start_with?("a")
  def chained = dir.strip.upcase
  def parens = (dir).upcase
  def cond = dir.empty? ? 1 : 2
  def interp = "#{dir.upcase}!"
  def each_block = dir.each { |x| p x }
  def statement
    dir.upcase
    :after
  end
  def safe = dir&.upcase
end

def t(label)
  yield
  p [label, :ok]
rescue NameError => e
  p [label, e.class, e.message]
end

u = U.new
t(:up) { u.up }
t(:subs) { u.subs }
t(:splits) { u.splits }
t(:size) { u.size }
t(:starts) { u.starts }
t(:chained) { u.chained }
t(:parens) { u.parens }
t(:cond) { u.cond }
t(:interp) { u.interp }
t(:each_block) { u.each_block }
t(:statement) { u.statement }
t(:safe) { u.safe }

def top = zork.upcase
t(:top) { top }

begin
  x = U.new.up
  p x
rescue NameError => e
  p [:value, e.message]
end
