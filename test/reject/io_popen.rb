# IO.popen is not implemented: a compile-time refusal, not a NoMethodError
# the first time the line runs (#7199).
def write_to_child
  IO.popen(["sh", "-c", "cat; exit 4"], "w") { |io| io.write("through popen\n") }
  p $?.to_i >> 8
end

write_to_child
