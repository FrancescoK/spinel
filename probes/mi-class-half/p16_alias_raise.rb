module M
  class E < StandardError; end
end
Al = M::E
begin
  raise Al, "x"
rescue M::E => e
  p e.class
end
