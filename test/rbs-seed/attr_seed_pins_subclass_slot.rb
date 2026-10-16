# spinel: rbs-seed-run
# `attr_accessor channel: String?` is declared once, in Sender. The seed
# pins Sender's @channel. Mailer inherits the slot and never assigns it,
# so its own passes read it as nil. The inherited slot was copied with
# the parent's type but without the pin, widened to poly, and the program
# was refused: "class layout: @channel is sp_RbVal in Mailer but const
# char * in its ancestor Sender". A pin on an ancestor's slot is a pin on
# the same slot of every class below it.
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

class Mailer < Sender
  def initialize
    super
    @drafts = []
  end

  def go
    send_text("hi")
  end
end

m = Mailer.new
p m.go
m.channel = "smtp"
p m.go
s = Sender.new
p s.send_text("x")
