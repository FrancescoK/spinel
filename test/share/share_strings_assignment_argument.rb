# spinel: gc-minor
# A String splice copies argument bytes into the receiver. Its result is
# the argument, so changing the receiver must not make that result mutable.
def captured_splice
  text = +"abcdef"
  other = text
  reader = -> { text }
  first = (text[0] = "X")
  run = (text[1, 2] = "YZ")
  range = (text[3..4] = "W")
  text << "!"
  p first, run, range, reader.call, other
  begin
    first << "?"
  rescue FrozenError => error
    p error.class
  end
end
captured_splice
