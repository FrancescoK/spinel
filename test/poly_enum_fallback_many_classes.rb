# A class that defines tally keeps its own method through a boxed receiver
# however many classes of the program have an #each and no Enumerable: each
# of those raises NoMethodError, the definer answers its own tally, and an
# Array answers the builtin one.
class E0; def each(&b) = [0].each(&b); end
class E1; def each(&b) = [1].each(&b); end
class E2; def each(&b) = [2].each(&b); end
class E3; def each(&b) = [3].each(&b); end
class E4; def each(&b) = [4].each(&b); end
class E5; def each(&b) = [5].each(&b); end
class E6; def each(&b) = [6].each(&b); end
class E7; def each(&b) = [7].each(&b); end
class E8; def each(&b) = [8].each(&b); end
class E9; def each(&b) = [9].each(&b); end
class E10; def each(&b) = [10].each(&b); end
class E11; def each(&b) = [11].each(&b); end
class E12; def each(&b) = [12].each(&b); end
class E13; def each(&b) = [13].each(&b); end
class E14; def each(&b) = [14].each(&b); end
class E15; def each(&b) = [15].each(&b); end
class E16; def each(&b) = [16].each(&b); end
class E17; def each(&b) = [17].each(&b); end
class E18; def each(&b) = [18].each(&b); end
class E19; def each(&b) = [19].each(&b); end
class E20; def each(&b) = [20].each(&b); end
class E21; def each(&b) = [21].each(&b); end
class E22; def each(&b) = [22].each(&b); end
class E23; def each(&b) = [23].each(&b); end
class E24; def each(&b) = [24].each(&b); end
class E25; def each(&b) = [25].each(&b); end
class E26; def each(&b) = [26].each(&b); end
class E27; def each(&b) = [27].each(&b); end
class E28; def each(&b) = [28].each(&b); end
class E29; def each(&b) = [29].each(&b); end
class E30; def each(&b) = [30].each(&b); end
class E31; def each(&b) = [31].each(&b); end
class E32; def each(&b) = [32].each(&b); end
class E33; def each(&b) = [33].each(&b); end
class E34; def each(&b) = [34].each(&b); end
class E35; def each(&b) = [35].each(&b); end
class E36; def each(&b) = [36].each(&b); end
class E37; def each(&b) = [37].each(&b); end
class E38; def each(&b) = [38].each(&b); end
class E39; def each(&b) = [39].each(&b); end
class E40; def each(&b) = [40].each(&b); end
class E41; def each(&b) = [41].each(&b); end
class E42; def each(&b) = [42].each(&b); end
class E43; def each(&b) = [43].each(&b); end
class E44; def each(&b) = [44].each(&b); end
class E45; def each(&b) = [45].each(&b); end
class E46; def each(&b) = [46].each(&b); end
class E47; def each(&b) = [47].each(&b); end
class E48; def each(&b) = [48].each(&b); end
class E49; def each(&b) = [49].each(&b); end
class E50; def each(&b) = [50].each(&b); end
class E51; def each(&b) = [51].each(&b); end
class E52; def each(&b) = [52].each(&b); end
class E53; def each(&b) = [53].each(&b); end
class E54; def each(&b) = [54].each(&b); end
class E55; def each(&b) = [55].each(&b); end
class E56; def each(&b) = [56].each(&b); end
class E57; def each(&b) = [57].each(&b); end
class E58; def each(&b) = [58].each(&b); end
class E59; def each(&b) = [59].each(&b); end
class E60; def each(&b) = [60].each(&b); end
class E61; def each(&b) = [61].each(&b); end
class E62; def each(&b) = [62].each(&b); end
class E63; def each(&b) = [63].each(&b); end
class Own; def each(&b) = [1].each(&b); def tally = :own_tally; end

class Holder
  def initialize(c) = @c = c
  def tallied = @c.tally
end

def try
  p yield
rescue NoMethodError => e
  puts "NoMethodError: #{e.message[/\A.*? an instance of \w+/]}"
end

objs = [
  E0.new, E1.new, E2.new, E3.new, E4.new, E5.new, E6.new, E7.new,
  E8.new, E9.new, E10.new, E11.new, E12.new, E13.new, E14.new, E15.new,
  E16.new, E17.new, E18.new, E19.new, E20.new, E21.new, E22.new, E23.new,
  E24.new, E25.new, E26.new, E27.new, E28.new, E29.new, E30.new, E31.new,
  E32.new, E33.new, E34.new, E35.new, E36.new, E37.new, E38.new, E39.new,
  E40.new, E41.new, E42.new, E43.new, E44.new, E45.new, E46.new, E47.new,
  E48.new, E49.new, E50.new, E51.new, E52.new, E53.new, E54.new, E55.new,
  E56.new, E57.new, E58.new, E59.new, E60.new, E61.new, E62.new, E63.new,
  Own.new, [1, 1, 2]
]
puts objs.size
[0, 63, 64, 65].each { |i| try { Holder.new(objs[i]).tallied } }
