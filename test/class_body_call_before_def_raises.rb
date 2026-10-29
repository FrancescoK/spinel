# A class body's call before its def that nothing rescues ends the program
# with CRuby's NameError; the statements after it do not run. The sidecar
# holds the error line as Spinel prints it.
puts "before"

# a call in an argument raises at the write, after the operands ahead of it
class Ops
  def self.id(x) = x
  def self.snd(a, b) = b
  def self.kw(a, k: 1) = k
  def self.noisy
    puts "noisy runs first"
    1
  end
  begin
    A = id(zz)
  rescue NameError => e
    puts e.message
  end
  begin
    B = snd(noisy, zz)
  rescue NameError => e
    puts e.message
  end
  begin
    C = id(id(zz))
  rescue NameError => e
    puts e.message
  end
  begin
    L = noisy&.then { zz }
  rescue NameError => e
    puts e.message
  end
  begin
    I = kw(1, k: zz)
  rescue NameError => e
    puts e.message
  end
  def self.zz = 5
end

class U
  zz
  def self.zz = 5
end
puts "not reached"
