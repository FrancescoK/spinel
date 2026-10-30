# A top-level collect_concat / detect is private: a call on an Array or a
# Range never reaches it and takes the builtin (flat_map / find), while a
# receiverless or self call still answers the program's method.
def collect_concat(x = 0)
  "top #{x}"
end
def detect
  "top detect"
end
a = [[1], [2]]
p a.collect_concat { |e| e }
p a.collect_concat.each { |e| e }
p a.send(:collect_concat) { |e| e }
p [3, 4, 5].detect { |e| e > 3 }
p (1..4).detect(&:even?)
puts collect_concat(3)
puts self.collect_concat(4)
puts detect
class K
  def run
    [collect_concat(5), detect, [[6]].collect_concat { |e| e }]
  end
  def self.crun
    [collect_concat(7), [8, 9].detect(&:odd?)]
  end
end
p K.new.run
p K.crun
