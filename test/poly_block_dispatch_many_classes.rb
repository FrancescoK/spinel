# A block call on a boxed receiver whose method more than 64 classes
# answer: the classes past the 64th were left out of the per-class switch
# and reached its default arm, which raised NoMethodError for a method
# they inherit. The call here also splats an argument
# (`body.each_node(:y, *TYPES)`).

class Node
  def each_node(*types)
    yield self if types.empty? || types.include?(:x)
    self
  end
end

class K1 < Node; end
class K2 < Node; end
class K3 < Node; end
class K4 < Node; end
class K5 < Node; end
class K6 < Node; end
class K7 < Node; end
class K8 < Node; end
class K9 < Node; end
class K10 < Node; end
class K11 < Node; end
class K12 < Node; end
class K13 < Node; end
class K14 < Node; end
class K15 < Node; end
class K16 < Node; end
class K17 < Node; end
class K18 < Node; end
class K19 < Node; end
class K20 < Node; end
class K21 < Node; end
class K22 < Node; end
class K23 < Node; end
class K24 < Node; end
class K25 < Node; end
class K26 < Node; end
class K27 < Node; end
class K28 < Node; end
class K29 < Node; end
class K30 < Node; end
class K31 < Node; end
class K32 < Node; end
class K33 < Node; end
class K34 < Node; end
class K35 < Node; end
class K36 < Node; end
class K37 < Node; end
class K38 < Node; end
class K39 < Node; end
class K40 < Node; end
class K41 < Node; end
class K42 < Node; end
class K43 < Node; end
class K44 < Node; end
class K45 < Node; end
class K46 < Node; end
class K47 < Node; end
class K48 < Node; end
class K49 < Node; end
class K50 < Node; end
class K51 < Node; end
class K52 < Node; end
class K53 < Node; end
class K54 < Node; end
class K55 < Node; end
class K56 < Node; end
class K57 < Node; end
class K58 < Node; end
class K59 < Node; end
class K60 < Node; end
class K61 < Node; end
class K62 < Node; end
class K63 < Node; end
class K64 < Node; end
class K65 < Node; end
class K66 < Node; end

TYPES = %i[x z].freeze

def count(body)
  c = 0
  body.each_node(:y, *TYPES) { |_n| c += 1 }
  c
end

nodes = [K1.new, K2.new, K3.new, K4.new, K5.new, K6.new, K7.new, K8.new, K9.new, K10.new, K11.new, K12.new, K13.new, K14.new, K15.new, K16.new, K17.new, K18.new, K19.new, K20.new, K21.new, K22.new, K23.new, K24.new, K25.new, K26.new, K27.new, K28.new, K29.new, K30.new, K31.new, K32.new, K33.new, K34.new, K35.new, K36.new, K37.new, K38.new, K39.new, K40.new, K41.new, K42.new, K43.new, K44.new, K45.new, K46.new, K47.new, K48.new, K49.new, K50.new, K51.new, K52.new, K53.new, K54.new, K55.new, K56.new, K57.new, K58.new, K59.new, K60.new, K61.new, K62.new, K63.new, K64.new, K65.new, K66.new, "not a node"]
p nodes.sum { |x| x.is_a?(String) ? 0 : count(x) }
p count(nodes[65])
p count(nodes[0])
