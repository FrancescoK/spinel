# respond_to? on an Integer read out of a container answers true for size,
# and on an Array for values_at, as on a typed one.
i = [5, "s"][0]
a = [[1, 2], "s"][0]
p [i.respond_to?(:size), 5.respond_to?(:size), i.size]
p [a.respond_to?(:values_at), [1, 2].respond_to?(:values_at), a.values_at(1)]
p [i.respond_to?(:values_at), a.respond_to?(:upcase)]
