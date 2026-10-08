# An `(untyped io)` sidecar signature makes a helper's buffer parameter POLY,
# and a POLY parameter the helper appends to pulls every caller's String into
# the shared handle (#5957). The page views below all take their buffer
# through `show_into`, a name two modules define: resolved by unique name,
# the call had no target, the caller's `io = String.new` stayed a plain local,
# and `Pages.show_into` got a fresh copy that took every append (#6065).
# spinel: rbs-seed-check
module SeedHelper
  def self.open_into(io)
    io << "<div>"
    nil
  end
end

module SeedRooms
  def self.show_into(io, n)
    SeedHelper.open_into(io)
    io << "room#{n}"
    nil
  end

  def self.show(n)
    io = String.new
    SeedRooms.show_into(io, n)
    io
  end
end

module SeedUsers
  def self.show_into(io, n)
    io << "user#{n}"
    nil
  end

  def self.show(n)
    io = String.new
    SeedUsers.show_into(io, n)
    io
  end
end

def seed_page_into(io)
  SeedHelper.open_into(io)
  io << "body"
  nil
end

def seed_page
  io = String.new
  seed_page_into(io)
  io
end

puts SeedRooms.show(1)
puts SeedUsers.show(2)
puts seed_page
