# A to_s whose body calls to_s on a box that may hold another of its
# objects: the route over a boxed receiver hands on the String itself.
Setup = Data.define(:ram, :model)
class Setup
  def to_s = model == "pal" ? ram.to_s : "#{ram} #{model}"
end

def show(x)
  s = +x.to_s   # (+: a Symbol's to_s is frozen in Spinel; the others are themselves)
  s << "!"
end

t = +"str"
p show(Setup.new(ram: :expanded, model: "pal"))
p show(Setup.new(ram: 8, model: "ntsc"))
p show(Setup.new(ram: Setup.new(ram: t, model: "pal"), model: "pal"))
p t
p show(Setup.new(ram: Setup.new(ram: Setup.new(ram: t, model: "pal"), model: "pal"), model: "pal"))
p t
p show(Setup.new(ram: Setup.new(ram: t, model: "pal"), model: "ntsc"))
p t
p Setup.new(ram: Setup.new(ram: t, model: "pal"), model: "pal").to_s.equal?(t)
p show(t), t
