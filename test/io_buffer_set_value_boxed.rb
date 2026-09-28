# set_value with a literal type symbol and a boxed value
buffer = IO::Buffer.new(16)
samples = [1, -2, nil].first(2)
2.times { |i| buffer.set_value(:s16, i * 2, samples[i]) }
mixed = [300, 2.5]
buffer.set_value(:s16, 4, mixed[0])
buffer.set_value(:F64, 8, mixed[1])
p buffer.get_value(:s16, 0), buffer.get_value(:s16, 2), buffer.get_value(:s16, 4)
p buffer.get_value(:F64, 8)
