# spinel: wasm-abort-refuse: a break out of a block that is not spliced into its method
def keep(&b) = b
pr = keep { break 3 }
p pr.call
