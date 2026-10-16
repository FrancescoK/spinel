# The same call reaches the module's split once the module is a value the
# parameter holds: the dispatch keeps its arm and joins both answers.
module Words
  def self.split(line) = [line, line.size]
end

ACCEPT = { list: ->(word) { word.split(",") } }

p ACCEPT[:list].call("a,,b")
p ACCEPT[:list].call(Words)
