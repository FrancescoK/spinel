# spinel: gc-stress
# IO.select and Kernel#select name a non-IO element of a descriptor set
# in their TypeError: nil, true and false by themselves, others by class.
class Plain; end

def try
  yield
rescue TypeError => error
  p [error.class, error.message]
end

try { IO.select([1], nil, nil, 0) }
try { IO.select(nil, ["x"], nil, 0) }
try { IO.select(nil, nil, [:sym], 0) }
try { IO.select([2.5], nil, nil, 0) }
try { IO.select([nil], nil, nil, 0) }
try { IO.select([true], nil, nil, 0) }
try { IO.select([false], nil, nil, 0) }
try { IO.select([{ a: 1 }], nil, nil, 0) }
try { IO.select([Plain.new], nil, nil, 0) }
try { IO.select([[1]], nil, nil, 0) }
try { IO.select(nil, [1..2], nil, 0) }
try { IO.select(nil, nil, [proc { 1 }], 0) }
try { IO.select([String], nil, nil, 0) }
try { IO.select([Kernel], nil, nil, 0) }
try { select([4], nil, nil, 0) }
try { Kernel.select(nil, ["y"], nil, 0) }
