# A local handed to a fiber's block, which appends to it, and read after the
# resume: the block's parameter takes a box of a copy, so the read would
# miss the append. Refused rather than compiled with the append lost.
f = +"f"
Fiber.new { |x| x << "!" }.resume(f)
p f
