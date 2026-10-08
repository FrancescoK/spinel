# Float#round(half:) picks the tie-break mode: :even (banker's), :down
# (toward zero), :up (the default away-from-zero).
# spinel: wasm
p 2.5.round(half: :even)
p 3.5.round(half: :even)
p 2.5.round(half: :up)
p 2.5.round(half: :down)
p(-2.5.round(half: :even))
p(-2.5.round(half: :down))
p 2.345.round(2, half: :even)
p 2.5.round(0, half: :even)
p 2.5.round
