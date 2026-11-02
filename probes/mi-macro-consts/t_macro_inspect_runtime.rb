# A macro that stores a String's inspect as data: when the text needs escapes
# the compile-time evaluator does not spell as CRuby does ("\e", "#", an
# operator Symbol), the inspect is left to run time, so the constant holds
# CRuby's text; plain values are inspected at compile time.
module Tags
  def tag(c, text) = const_set(c, text.inspect)
  def list(c, names) = const_set(c, "#{names}")
end
class T
  extend Tags
  tag :ESC, "a\e#b\r"
  tag :PLAIN, "ab"
  list :OPS, [:+, :@x, :[]]
  list :IDS, [:a, :b?]
end
p T::ESC, T::PLAIN, T::OPS, T::IDS
