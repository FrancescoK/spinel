# A String mutator whose receiver is a parenthesized sequence, a conditional
# or an `||` answering a variable is sent to that variable's String. The
# rewrite that moves the call onto the variable took a String-typed receiver
# only, and a boxed one reached the boxed dispatch, which reassigns only a
# variable: prepend and concat raised NoMethodError, and the other mutators
# changed a copy.

def t(k)
  log = []
  %w[prepend insert concat replace << upcase! clear sub! []= delete_prefix! squeeze! reverse! slice!].each do |m|
    s = [+"xyx", 1][k]
    r = case m
        when "prepend" then (log << :r; s).prepend("a")
        when "insert" then (log << :r; s).insert(1, "b")
        when "concat" then (log << :r; s).concat("c")
        when "replace" then (log << :r; s).replace("zz")
        when "<<" then (log << :r; s) << "d"
        when "upcase!" then (log << :r; s).upcase!
        when "clear" then (log << :r; s).clear
        when "sub!" then (log << :r; s).sub!("x", "Z")
        when "[]=" then (log << :r; s)[0] = "Q"
        when "delete_prefix!" then (log << :r; s).delete_prefix!("x")
        when "squeeze!" then (log << :r; s).squeeze!
        when "reverse!" then (log << :r; s).reverse!
        when "slice!" then (log << :r; s).slice!(0)
        end
    puts "#{m}: #{r.inspect} #{s.inspect}"
  end
  p log.size

  s = [+"xy", 1][k]
  u = [nil, +"uu"][k]
  (k == 0 ? s : u).prepend("w")
  (u || s).concat("o")
  @v = nil
  (@v ||= [+"v", 1][k]) << "x"
  (@v ||= [+"v2", 1][k]) << "y"
  (log << :a; (log << :b; s)).insert(0, "i")
  p s, u, @v

  a = [[1], 2][k]
  (log << :c; a) << 5
  (log << :d; a).concat([6])
  p a
  h = [{1 => 2}, 1][k]
  (log << :e; h).merge!({3 => 4})
  p h, log.size
end

t(ARGV.size)
