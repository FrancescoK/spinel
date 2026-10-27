# A module's native_func answers what its binding declares, a builtin
# value, at every call: JSON.parse of a document JSON.generate wrote from
# Money values does not hand them to the parsed settings, so a setting's
# to_i has no Money#to_i arm (#10303).
require "json"

SETTINGS = JSON.parse('{"retries": 3}')

def setting(name)
  value = SETTINGS[name]
  value.to_i
end

class Money
  def initialize(cents) = @cents = cents
  def to_i = @cents
  def to_json(*) = @cents.to_s
end

class Task
end

class Export < Task
  def call
    @payload = [Money.new(5), Money.new(7)]
    JSON.generate(@payload)
  end
end

class Import < Task
  def call = JSON.parse(Export.new.call)
end

p Import.new.call
p setting("retries")
p Money.new(5).to_i
