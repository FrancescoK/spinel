# An exception's message override is asked by the runtime where the exception
# is printed, so the private helper only it calls is compiled too (sqlite3's
# SQLite3::Exception#sql_error), though no program code calls `message`.
class QueryError < StandardError
  attr_reader :sql, :sql_offset

  def message
    [super, sql_error].compact.join(":\n")
  end

  private def sql_error
    return nil unless @sql
    return @sql.chomp unless @sql_offset >= 0

    offset = @sql_offset
    sql.lines.flat_map do |line|
      if offset >= 0 && line.length > offset
        blanks = " " * offset
        offset = -1
        [line.chomp, blanks + "^"]
      else
        offset -= line.length if offset
        line.chomp
      end
    end.join("\n")
  end
end

def boom(sql, off)
  e = QueryError.new("near x")
  e.instance_variable_set(:@sql, sql)
  e.instance_variable_set(:@sql_offset, off)
  raise e
end

begin
  boom("select * frm t\nwhere 1", 9)
rescue QueryError => e
  puts e.inspect
end
begin
  boom("select 1\n", -1)
rescue QueryError => e
  p e
end
begin
  raise QueryError, "plain"
rescue QueryError => e
  puts e.message
  p e.sql
end
