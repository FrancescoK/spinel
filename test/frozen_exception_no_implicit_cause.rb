# A frozen exception takes no implicit cause, as in CRuby; an unfrozen one
# takes the exception being handled (#8276).
[true, false].each do |fz|
  e = RuntimeError.new("e")
  e.freeze if fz
  begin
    raise "outer"
  rescue
    begin
      raise e, cause: nil
    rescue
    end
    begin
      raise e
    rescue => caught
      p [fz, caught.cause&.message]
    end
  end
  f = RuntimeError.new("f")
  f.freeze if fz
  begin
    raise "outer2"
  rescue
    begin
      raise f
    rescue => c2
      p [fz, :first, c2.cause&.message]
    end
  end
end
