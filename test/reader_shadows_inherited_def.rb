# A subclass's attr_reader overrides the method of the same name it
# inherits. On a boxed receiver the call dispatches to each reader, so it
# answers what they read: here an Array of Strings, while the base method
# only raises. The call was typed from the inherited method alone, and
# the C did not compile. tzinfo's data sources are built this way
# (DataSource#country_codes and the readers that override it).
class DS
  def codes
    raise NotImplementedError
  end
end
class RDS < DS
  attr_reader :codes
  def initialize = @codes = ["a", "b"]
end
class ZDS < DS
  attr_reader :codes
  def initialize = @codes = ["c"]
end
def all(ds) = ds.codes.collect { |c| c.upcase }
p all(RDS.new)
p all(ZDS.new)
