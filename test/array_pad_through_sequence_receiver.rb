# A write into an Array held in parentheses that run statements first,
# `(log << 1; a)[i] = v`, lands in `a`, the sequence's value. The Array a
# computed-index write past its end pads with nil, and the receiver that
# carried the mark through a parenthesis was read as no Array at all when the
# parentheses held more than one statement: the pad was not seen, and
# `a.map { |x| x.nil? }` answered all false.
$log = []
def lg(x) = ($log << x; x)

a = [1, 2]
i = 4 + ARGV.size
(lg(:a1); a)[i] = 7
p a
p a.map { |x| x.nil? }
p a.include?(nil)

b = [1.5]
j = 3 + ARGV.size
((lg(:b1); lg(:b2); b))[j] = 2.5
p b
p b.map { |x| x.nil? }

class Holder
  def initialize; @a = [1]; end
  def put(i, v)
    (lg(:h1); @a)[i] = v
    @a
  end
end
r = Holder.new.put(3 + ARGV.size, 8)
p r
p r.map { |x| x.nil? }

# a single statement and a bare receiver pad the same way
c = [1]
(c)[3 + ARGV.size] = 5
p c.map { |x| x.nil? }
d = [1]
d[3 + ARGV.size] = 5
p d.map { |x| x.nil? }

# a receiver chain through a sequence
e = [1]
((lg(:e1); e) << 2)[4 + ARGV.size] = 6
p e
p e.map { |x| x.nil? }
p $log
