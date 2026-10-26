# `new` on a value that holds the program's Class objects and a builtin
# one (a block parameter over an Array of classes) makes an instance of
# each of those classes, and a runtime value for the builtin part: Money,
# which nothing makes there, does not reach a parsed setting's to_i (#10303).
require "json"
require "csv"

SETTINGS = JSON.parse('{"retries": 3}')

def setting(name)
  value = SETTINGS[name]
  value.to_i
end

class Money
  def initialize(cents) = @cents = cents
  def to_i = @cents
end

class Task
end

class Export < Task
  def call
    @payload = [1, 2]
    JSON.generate(@payload)
  end
end

class Import < Task
  def call
    @payload = "1,2\n"
    CSV.parse(@payload)
  end
end

[Export, Import].each { |task| p task.new.call }
p JSON.parse(Export.new.call)
p setting("retries")
p Money.new(5).to_i
