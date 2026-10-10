# spinel: reject-syntax: Invalid retry (SyntaxError)
# A retry in an ensure clause is CRuby's SyntaxError, though a rescue
# encloses the begin it sits in (#8377).
n = 0
begin
  n += 1
  raise "again" if n < 2
rescue
  begin
    nil
  ensure
    retry
  end
end
p n
