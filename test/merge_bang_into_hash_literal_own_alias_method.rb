# A Hash#merge! of the program's own, bound with alias_method, is kept for
# a Hash literal receiver.
class Hash
  def loud_merge(o) = (puts "alias_method merge!"; self)
  alias_method :merge!, :loud_merge
end

p({}.merge!({ a: 1 }))
