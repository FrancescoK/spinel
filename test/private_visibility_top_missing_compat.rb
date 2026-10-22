# spinel: not-cruby
# A top-level missing hook is Object's method and keeps master's answers.
def method_missing(name, *args) = "mm:#{name}"
class MissingViaTopObject
  private def x = 6
  def run = (self).x
end
p MissingViaTopObject.new.run
def missing_top_helper = 7
p((self).missing_top_helper)
