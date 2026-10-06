# An arm of a value-position if or ternary that raises NoMethodError (a call
# no class defines on a typed receiver) beside a String arm: parenthesized,
# as the left of &&, or as a chain nested in another chain (#7164 follow-up).
class Box
  def show(email, name: "")
    email + "/" + name
  end

  def paren(item)
    x = item.empty? ? "" : (item.owner)
    x
  end

  def chain(item)
    x = if item.empty?
      ""
    else
      item.owner && item.owner.email
    end
    x
  end

  def nested(item)
    show(item.empty? ? "" : (item.owner && item.owner.email && (item.owner && item.owner.email).downcase),
         name: item.empty? ? "" : (item.owner.name && item.owner.name.split && (item.owner.name && item.owner.name.split).first))
  end
end

b = Box.new
puts b.show("a@b", name: "x")
p b.paren({})
p b.chain({})
p b.nested({})
h = { "a" => 1 }
begin; b.paren(h);  rescue NoMethodError => e; puts e.message; end
begin; b.chain(h);  rescue NoMethodError => e; puts e.message; end
begin; b.nested(h); rescue NoMethodError => e; puts e.message; end
puts "done"
