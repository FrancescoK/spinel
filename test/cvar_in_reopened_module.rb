# A class variable first written in a reopening of the module, not the body
# that defined it, is declared on the module (sdl2-bindings spreads one
# module over several files).
module SDLx
  def self.other = 1
end
module SDLx
  @@done = false
  def self.load(path)
    puts "loading #{path}" unless @@done
  end
end
SDLx.load("x")
