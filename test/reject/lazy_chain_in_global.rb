# spinel: reject-lazy: a lazy chain held in an instance, class or global variable or a constant
# The same for a global (#9160).
$lazy = [1, 2, 3].lazy
p $lazy.map { |x| x + 1 }.to_a
