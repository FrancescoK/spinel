# A program class with a respond_to? of its own answers for its objects;
# a builtin value -- an empty Array literal, a Hash, a String -- still
# answers through the builtin's (tzinfo asks `[].respond_to?(:bsearch)`).
class Zone
  def respond_to?(name, include_all = false) = name == :zone || super
end
p [].respond_to?(:bsearch_index), [].respond_to?(:nope)
p({}.respond_to?(:each_pair), "s".respond_to?(:upcase), 1.respond_to?(:times))
p Zone.new.respond_to?(:zone), Zone.new.respond_to?(:nope)
if [].respond_to?(:bsearch)
  puts "has bsearch"
end
