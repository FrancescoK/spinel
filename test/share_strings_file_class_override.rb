# spinel: share
# spinel: gc-minor
# User singleton methods on File keep their own mutation and return aliases,
# whether defined in a reopening, directly, or through the singleton class.
class File
  def self.readable?(value)
    value << "!"
    value
  end
end

def File.writable?(value)
  value << "!"
  value
end

class << File
  def executable?(value)
    value << "!"
    value
  end
end

module FilePredicateOverride
  def exist?(value)
    value << "!"
    value
  end
end
class File
  singleton_class.prepend(FilePredicateOverride)
end

readable = +"readable"
readable_answer = File.readable?(readable)
readable_answer << "?"
p readable
p readable_answer
writable = +"writable"
writable_answer = File.writable?(writable)
writable_answer << "?"
p writable
p writable_answer
executable = +"executable"
executable_answer = File.executable?(executable)
executable_answer << "?"
p executable
p executable_answer
existing = +"existing"
existing_answer = File.exist?(existing)
existing_answer << "?"
p existing
p existing_answer

# A FileTest override keeps the same mutation and return aliases.
module FileTest
  def self.readable?(value)
    value << "!"
    value
  end
end
filetest = +"filetest"
filetest_answer = FileTest.readable?(filetest)
filetest_answer << "?"
p filetest
p filetest_answer
