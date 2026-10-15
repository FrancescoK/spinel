class Item
  #: () -> untyped
  def done? = true
end

class Notifier
  #: () -> bool
  def self.notify
    changed = yield
    changed
  end
end

p Notifier.notify { Item.new.done? }
