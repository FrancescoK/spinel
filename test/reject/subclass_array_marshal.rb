# An Array subclass instance is boxed as its Array, so Marshal.dump would
# write a plain Array and drop its class and instance variables: refused
# where the instance is dumped (#7449).
class Page < Array
  def initialize(records, source)
    super(records)
    @source = source
  end
end

data = Marshal.dump(Page.new([1, 2], "room"))
p Marshal.load(data).class
