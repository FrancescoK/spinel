# A bare name nothing defines raises NameError at its first read, also as the
# left operand of && / || or the receiver in an if, beside a String, a
# Symbol or an object on the other side (#7164).
class Shop
  def self.first = Shop.new
end

class Widget
  def shop
    owner && owner.shop || Shop.first
  end

  def label
    owner && owner.name || "none"
  end

  def kind
    if owner.admin?
      owner.kind
    else
      :basic
    end
  end
end

w = Widget.new
begin; w.shop;  rescue NameError => e; puts e.message; end
begin; w.label; rescue NameError => e; puts e.message; end
begin; w.kind;  rescue NameError => e; puts e.message; end
puts "done"
