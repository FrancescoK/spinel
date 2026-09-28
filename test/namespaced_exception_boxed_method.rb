module Storage
  class WriteError < StandardError
    attr_reader :code
    def initialize(code)
      @code = code
      super("DOS error #{code}")
    end
    def label = "E#{code}"
  end
  class DeepError < WriteError
    def depth = code + 1
  end
end

class WriteError < StandardError
  attr_reader :who
  def initialize(who)
    @who = who
    super("top #{who}")
  end
  def label = "top-#{who}"
end

module A
  module B
    class Err < StandardError
      attr_reader :n
      def initialize(n)
        @n = n
        super("ab #{n}")
      end
      def twice = n * 2
    end
  end
end

module Writes
  def writing
    yield
  rescue Storage::WriteError => e
    puts e.code
    puts e.message
    puts e.label
    puts e.class
  end

  def top_writing
    yield
  rescue WriteError => e
    puts e.who
    puts e.label
  end

  def ab
    yield
  rescue A::B::Err => e
    puts e.n
    puts e.twice
  end

  def any
    yield
  rescue => e
    puts(e.is_a?(Storage::WriteError) && e.code)
  end
end

class Drive
  include Writes
  def save = writing { raise Storage::WriteError, 26 }
  def deep = writing { raise Storage::DeepError, 7 }
  def top = top_writing { raise WriteError, "x" }
  def abc = ab { raise A::B::Err, 21 }
  def any1 = any { raise Storage::WriteError, 3 }
  def any2 = any { raise A::B::Err, 4 }
end

d = Drive.new
d.save
d.deep
d.top
d.abc
d.any1
d.any2

module Fns
  def self.run
    yield
  rescue Storage::WriteError => e
    puts "fn #{e.code} #{e.label}"
  end
end
Fns.run { raise Storage::DeepError, 9 }

class K
  def self.run
    yield
  rescue A::B::Err => e
    puts "cm #{e.twice}"
  end
end
K.run { raise A::B::Err, 5 }

[1].each do
  begin
    raise Storage::WriteError, 11
  rescue Storage::WriteError => e
    puts "blk #{e.code} #{e.label}"
  end
end
