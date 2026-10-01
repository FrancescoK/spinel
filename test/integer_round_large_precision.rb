# spinel: int64 -- precision 1 << 31 exceeds a 32-bit Integer
begin
  p 42.round(1 << 31)
rescue => e
  p e.class
end

# The same limit applies to the keyword and boxed-receiver paths.
n = 1 << 31
begin
  p [:keyword, 42.round(n, half: :up)]
rescue => e
  p [:keyword, e.class]
end
value = [42, 'other'][0]
begin
  p [:boxed, value.round(n)]
rescue => e
  p [:boxed, e.class]
end
begin
  p [:boxed_keyword, value.round(n, half: :up)]
rescue => e
  p [:boxed_keyword, e.class]
end

begin
  p [:bignum, (2**70).round(n)]
rescue => e
  p [:bignum, e.class]
end

p 42.round((1 << 31) - 1)
