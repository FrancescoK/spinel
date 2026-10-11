# A call to a method the program never defines, written in a begin that
# rescues NameError or NoMethodError, raises CRuby's NoMethodError there.
# RDoc's executable opens with this probe for RubyGems, `gem "rdoc"` rescued
# as NameError for --disable-gems: a Spinel program has no RubyGems, so its
# `gem` is such a call. The names here are missing under CRuby too.
begin
  load_gem "rdoc"
rescue NameError => e
  raise unless e.name == :load_gem
  p e.class
  p e.name
  puts e.message
end

# the arguments are still evaluated first
def note(s)
  puts "evaluating #{s}"
  s
end

begin
  activate note("json"), 2
rescue NoMethodError => e
  p e.name
end

# inside a method of a class, and from a later rescue clause
class Loader
  def load_yaml
    begin
      load_gem "psych"
    rescue ArgumentError
      :wrong
    rescue NoMethodError, NameError => e
      e.message
    end
  end
end
puts Loader.new.load_yaml

# the begin answers what its rescue does
x = begin
  load_gem "rake"
  :loaded
rescue NameError
  :no_gems
end
p x
