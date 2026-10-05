# A String subclass instance is boxed as a String handle, so Marshal.dump
# would write a plain String and drop its class and instance variables:
# refused where the instance is dumped (#7449).
class Note < String
  def initialize(s, by)
    super(s)
    @by = by
  end
end

data = Marshal.dump(Note.new("hi", "ann"))
p Marshal.load(data).class
