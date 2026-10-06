# A class body's `self.x = v` and `self.x` reach a private class method an
# attr_accessor / attr_reader / attr_writer in `class << self` made, however
# it was made private: `self.` is a literal self receiver. Ragel's Ruby
# backend writes its state tables this way. An explicit receiver is still
# refused.
class Tables
  class << self
    attr_accessor :_trans_keys
    private :_trans_keys, :_trans_keys=
  end
  self._trans_keys = [1, 2]
  p self._trans_keys
  p send(:_trans_keys)
end

module Mod
  class << self
    attr_accessor :tbl
    private :tbl=
  end
  self.tbl = [3]
  p tbl
end

class Section
  class << self
    private
    attr_accessor :tbl
  end
  self.tbl = [4]
  p self.tbl
end

class Writer
  class << self
    attr_writer :tbl
  end
  private_class_method :tbl=
  self.tbl = [5]
  p @tbl
end

class Reader
  @tbl = [6]
  class << self
    attr_reader :tbl
    private :tbl
  end
  p self.tbl
end

class Explicit
  class << self
    attr_accessor :tbl
    private :tbl=
  end
  begin
    Explicit.tbl = 7
  rescue NoMethodError => e
    puts e.message
  end
end

begin
  Tables._trans_keys = 8
rescue NoMethodError => e
  puts e.message
end
