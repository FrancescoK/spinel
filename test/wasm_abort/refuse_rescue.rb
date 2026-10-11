# spinel: wasm-abort-refuse: rescue needs exception handling, which --exceptions=abort leaves out
begin
  Integer("x")
rescue ArgumentError
  p :caught
end
