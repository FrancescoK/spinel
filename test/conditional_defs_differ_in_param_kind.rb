# Two conditional definitions of one method that differ only in the kind of a
# block parameter -- `|a, **nil|` against `|a,|` -- are two different
# definitions, so the one the condition picks is the one that runs: with no
# argument the first (a keeps the whole array, `**nil` says no keywords), with
# one the second (the trailing comma destructures, a is the first element).
# The definitions were once taken for the same one, and the second always ran.
if ARGV.empty?
  def m = proc { |a, **nil| a }.call([1, 2])
else
  def m = proc { |a,| a }.call([1, 2])
end
p m

if ARGV.empty?
  def n = proc { |a,| a }.call([3, 4])
else
  def n = proc { |a, **nil| a }.call([3, 4])
end
p n
