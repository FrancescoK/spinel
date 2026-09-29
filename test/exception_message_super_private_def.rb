# `super` from an exception subclass's own #message reaches Exception#message
# -- the text it was raised with -- and a private def the override calls.
# (sqlite3's SQLite3::Exception#message.)
module SQ
  class Exception < ::StandardError
    attr_reader :sql
    def message
      [super, sql_error].compact.join(":\n")
    end
    private def sql_error
      return nil unless @sql
      "near: #{@sql}"
    end
  end
  class SQLException < Exception
    def initialize(msg, sql = nil)
      super(msg)
      @sql = sql
    end
  end
end
begin
  raise SQ::SQLException.new("boom", "select x")
rescue SQ::Exception => e
  p e.message
end
