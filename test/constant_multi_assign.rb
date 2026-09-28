R, W = IO.pipe
W.write("hi")
W.close
p R.read

SR, SW = *IO.pipe
SW.write("splat")
SW.close
p SR.read

module Pipes
  PR, PW = IO.pipe
  def self.roundtrip
    PW.write("mod")
    PW.close
    PR.read
  end
end
p Pipes.roundtrip

A, B = [1, nil]
p A, B

X, Y, Z = [1, "two"]
p X, Y, Z

def read_consts
  [B, Y, Z]
end
p read_consts
