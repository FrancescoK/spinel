# A Hash read out of an Array keeps Hash#[] in a program that requires set,
# whose Set defines a class method `[]`: the boxed read is no Class, so the
# class's self.[] does not take it (#10496, fixed by #10363).
require "set"

class Probe
  OPTIONS = { in: [ "admin", "root" ] }
  ENTRY = [ "WordsForm", :word, :inclusion, OPTIONS ]

  def self.run
    p ENTRY[3][:in]
    p ENTRY[3].respond_to?(:[])
    p ENTRY.last.fetch(:in).size
  end
end

Probe.run
h = { k: Set[1, 2] }
p [0, h][1][:k].size
