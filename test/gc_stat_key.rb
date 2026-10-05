# GC.stat(key) answers that one statistic, an Integer, and raises CRuby's
# ArgumentError for a key the collector does not keep. It was refused as
# an undefined class method. activesupport's instrumentation events read
# GC.stat(:total_allocated_objects) where GC.stat has the key.
k = GC.stat.keys.first
p GC.stat(k.to_sym).is_a?(Integer)
begin
  GC.stat(:no_such_statistic)
rescue ArgumentError => e
  p e.message
end
