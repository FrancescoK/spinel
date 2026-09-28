module Validator
  def self.check(code, filename = "(eval)")
    puts "#{code}@#{filename}"
  end
end

def run(object, *args)
  object.check(*args)
end

Validator.check(1, "direct")
run(Validator, "x")
run(Validator, :y, "f.rb")
run(1, 2) rescue puts "nope"
