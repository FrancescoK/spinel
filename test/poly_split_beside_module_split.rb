# A lambda's untyped parameter calls #split, and a module defines its own
# split, answering a mixed Array, that the program only calls by name. The
# module is never a value the parameter can hold, so the call is a String's
# split: shellwords' split beside optparse's Array acceptor.
module Words
  def self.split(line) = [line, line.size]
end

ACCEPT = { list: ->(word) { word.split(",") } }

p ACCEPT[:list].call("a,,b")
p Words.split("x y")
