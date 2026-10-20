# Exception#detailed_message(highlight: true) bolds the message lines and
# underlines the class name; other highlight values raise ArgumentError.
["boom", "", "a\nb\nc", "a\n", "a\n\n", "\na", "\n", "a\nb\n", "\e[31mred\e[0m"].each do |m|
  p RuntimeError.new(m).detailed_message(highlight: true)
end
p Exception.new("").detailed_message(highlight: true)
p TypeError.new("bad").detailed_message(highlight: true)
p RuntimeError.new("a\0b").detailed_message(highlight: true).bytes

p RuntimeError.new("").detailed_message(highlight: false)
p RuntimeError.new("a\nb").detailed_message(highlight: nil)
p RuntimeError.new("boom").detailed_message(other: true)

e = RuntimeError.new("boom")
[true, false, nil, 1, "yes", :yes].each do |h|
  begin
    p e.detailed_message(highlight: h)
  rescue => error
    p [error.class, error.message]
  end
end

kw = {highlight: true}
p e.detailed_message(**kw)
off = {highlight: false}
p e.detailed_message(highlight: true, **off)
p Thread.new { RuntimeError.new("thread").detailed_message(highlight: true) }.value
p Fiber.new { RuntimeError.new("fiber").detailed_message(highlight: true) }.resume

anon = Class.new(RuntimeError)
["m", "m\nn", "a\n", "a\nb\n"].each do |m|
  p anon.new(m).detailed_message(highlight: true)
end
