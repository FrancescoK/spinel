# const_get / const_defined? with a name computed at run time look the name
# up among the module's constants.
module Arch
  COMPRESSION_GZIP = 1
  COMPRESSION_XZ = 6
  class Reader; end
end
%i[gzip xz].each { |c| p Arch.const_get("COMPRESSION_#{c.to_s.upcase}".to_sym) }
p Arch.const_get("Reader")
p Arch.const_defined?("COMPRESSION_" + "XZ"), Arch.const_defined?("NOPE".to_s)
begin
  Arch.const_get("NOPE".downcase.upcase)
rescue NameError => e
  p e.class
end
