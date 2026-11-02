class Opt
  Version = "1.0"
  def v = (defined?(::Version) ? ::Version : :none)
end
p Opt.new.v
