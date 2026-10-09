# A fill block stores its String result as a handle on every turn.
s = +"f"
b = [+"x", +"y"]
b.fill { |i| s }
b[1] << "?"
p [s, b]
b.fill(0, 1) { |i| +"z" }
b[0] << "!"
p [s, b]
