# A String that is appended to is boxed as its handle, and an Integer's
# bit operator or shift with it as the operand raises as for any String
# rather than reading it as 0.
n = [String.new("bad"), 1.5].first
n << "x"
[->(v) { 1 << v }, ->(v) { 1 >> v }, ->(v) { 6 & v }, ->(v) { 6 | v }, ->(v) { 6 ^ v }].each do |f|
  begin
    p f.call(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end
