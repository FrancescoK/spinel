# A Complex or a Rational handed to an Array or Hash op whose arm binds the
# argument into a typed slot. Both are by-value structs (sp_Complex,
# sp_Rational), and the arms that name the other classes an argument can
# have (zip's scalar list, the no-#to_ary kinds, the key kinds a typed table
# misses on, merge's no-#to_hash class name) left them out, so each reached
# the line that assigns the argument to an array, key or hash pointer and the
# generated C did not build. A Complex exponent's boxed form had no arm at
# all: sp_poly_pow's boxed answer went into sp_box_complex.

def t(k)
  c = Complex(1, 2)
  q = Rational(1, 2)

  # zip: neither responds to :each, and a Time neither; a String Range does
  begin; p([1, 2].zip(c)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p([[1], [2]].zip(q)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p([1.5].zip([3], q)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p([1, 2].zip(Time.at(0))); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p([1, 2].zip("a".."c")); rescue => e; puts "#{e.class}: #{e.message}"; end

  # concat, product, union: no #to_ary
  begin; p([[1, 2]].concat(c)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p([1, 2].concat(q)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p([1, 2].product(c)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(["a"].union(q)); rescue => e; puts "#{e.class}: #{e.message}"; end

  # Hash keys: no String, Symbol or Integer is eql? to either
  h = {"a" => 1}
  begin; p(h.fetch(c, 0)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.fetch(q)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.values_at(c, "a")); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.fetch_values(q)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.slice(c, "a")); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.except(q)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.key?(c)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.delete(q)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(h.dig(c)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p({:a => 1}.except(c)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p({1 => 2}.slice(q, 1)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p({1 => 2}.key?(Rational(1, 1))); rescue => e; puts "#{e.class}: #{e.message}"; end

  # merge: no #to_hash
  begin; p(h.merge(c)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p({1 => 2}.merge(q)); rescue => e; puts "#{e.class}: #{e.message}"; end

  # a boxed exponent picks the power by its class at run time
  begin; p(c ** [2, q][k]); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(c ** [Rational(4, 2), 1][k]); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(c ** [:s, 1][k]); rescue => e; puts "#{e.class}: #{e.message}"; end

  # pack on a receiver that may be nil: a format of another class is the
  # String slot's TypeError, as on a plain Array
  r = k == 0 ? [65, 66] : nil
  begin; p(r.pack(5)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(r.pack(:C2)); rescue => e; puts "#{e.class}: #{e.message}"; end
  begin; p(r.pack("C2")); rescue => e; puts "#{e.class}: #{e.message}"; end
end

t(ARGV.size)
