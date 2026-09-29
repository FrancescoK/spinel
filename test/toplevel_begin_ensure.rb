# A top-level begin/ensure: the main body is a void C function, so the ensure
# epilogue returns bare (gcc 14+ rejects `return 0;` there). A Thread body
# inside it is its own sp_int function and still returns a value.
begin
  puts "body"
  t = Thread.new do
    :inner
  ensure
    puts "thread ensure"
  end
  p t.value
ensure
  puts "ensure"
end
