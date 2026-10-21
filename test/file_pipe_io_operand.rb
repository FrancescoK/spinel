# spinel: gc-stress
r, w = IO.pipe
p [File.pipe?(r), File.pipe?("README.md")]
p File.pipe?(w)
r.close
w.close
