# spinel: rbs-seed-run
# The base class declares `attr_accessor channel: String?` and the
# subclass declares the same attribute as Integer?. The two structs must
# share a prefix, so the subclass's slot takes the ancestor's pinned type,
# with a warning that its own pin was dropped (the same yielding as a
# child pin under an ancestor's inferred type), and the program runs on
# the base class's String.
class Sender
  def initialize
    @sent = 0
  end

  attr_accessor :channel

  def send_text(text)
    @sent += 1
    if @channel
      "#{text} via #{@channel}"
    else
      text
    end
  end
end

class Pager < Sender
  def initialize
    super
    @beeps = 0
  end

  def go
    send_text("hi")
  end
end

pg = Pager.new
p pg.go
pg.channel = "pager"
p pg.go
