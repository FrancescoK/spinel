# A String built in place is a String to grep, grep_v, any?, all? and a
# class held in a variable, as a plain String element is.
s = +"ab"
s << "c"
a = [s, 1]
p a.grep(String)
p a.any?(String)
p a.grep_v(String)
p [s, :t].count { |v| String === v }
p a.all?(Comparable)
k = String
p a[0].instance_of?(k)
# a builder slot that holds nil is no String
x = nil
x = +"a" if ARGV.size > 5
x << "b" if ARGV.size > 5
p [x, 1].any?(String)
