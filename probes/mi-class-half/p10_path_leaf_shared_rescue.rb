module A
  class Err < StandardError; end
end
module B
  class Err < StandardError; end
end
begin
  raise B::Err, "b"
rescue A::Err
  p :a
rescue B::Err => e
  p [:b, e.message]
end
