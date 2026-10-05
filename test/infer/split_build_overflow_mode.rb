# Built split (--jobs) under --int-overflow=promote and =wrap by infer-test:
# each part has to be compiled in the requested overflow mode. The define
# reached only the link, so a split build raised RangeError here where an
# unsplit one made a Bignum or wrapped. (Raise mode, the default build of
# this directory, rescues.)
a = 1 << 62
begin
  p a * 4 + 7
  p a << 3
rescue RangeError
  p :overflow
end
