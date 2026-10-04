# A mutator called on a frozen string literal evaluates its arguments,
# then raises FrozenError; []= on a literal is one of them.
def i
  puts "index"
  0
end

def v
  puts "value"
  "J"
end

begin
  "hello"[i] = v
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello"[1, 2] = "J"
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello"[1..2] = "J"
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello"["ll"] = "LL"
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello"[/l+/] = "L"
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello".insert(i, v)
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello".prepend(v)
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello" << v
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello".delete_prefix!(v)
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  "hello" << v << i.to_s
rescue => e
  puts "#{e.class}: #{e.message}"
end
