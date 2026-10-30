# A retained constant receiver leaves its value in every tail context.
module Target
  class C
    def self.v = 3
  end
end
module M
  def self.in_proc
    proc { M::H::C.v }.call
  end
  def self.in_lambda
    -> { M::H::C.v }.call
  end
  def self.in_loop
    loop { break M::H::C.v }
  end
  def self.in_ensure
    begin; M::H::C.v; ensure; 0; end
  end
  def self.in_case
    case 1; when 1 then M::H::C.v; else 0; end
  end
  def self.in_and
    true && M::H::C.v
  end
  def self.in_then
    1.then { M::H::C.v }
  end
  def self.in_inject
    [1, 2].inject(0) { |s, x| s + M::H::C.v }
  end
  def self.in_select
    [1, 2].select { |x| M::H::C.v > x }
  end
end
begin
  p M.in_proc
rescue NameError => e
  puts e.message
end
begin
  p M.in_lambda
rescue NameError => e
  puts e.message
end
begin
  p M.in_loop
rescue NameError => e
  puts e.message
end
begin
  p M.in_ensure
rescue NameError => e
  puts e.message
end
begin
  p M.in_case
rescue NameError => e
  puts e.message
end
begin
  p M.in_and
rescue NameError => e
  puts e.message
end
begin
  p M.in_then
rescue NameError => e
  puts e.message
end
begin
  p M.in_inject
rescue NameError => e
  puts e.message
end
begin
  p M.in_select
rescue NameError => e
  puts e.message
end
M::H = Target
p M.in_proc
p M.in_lambda
p M.in_loop
p M.in_ensure
p M.in_case
p M.in_and
p M.in_then
p M.in_inject
p M.in_select
