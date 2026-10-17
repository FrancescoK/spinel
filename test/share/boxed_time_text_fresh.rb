# A boxed Time's text forms answer a new String, as a typed Time's do: the
# share check reads them from the builtin's rows, so a Hash literal that
# holds one beside a String the program keeps is not refused, and an append
# to either changes only that one.
def tag(d, attrs) = attrs.merge({ datetime: d.iso8601, data: { k: 1 } })
times = [Time.at(0).utc, Time.at(5).utc]
held = +"keep"
h = tag(times[ARGV.size], { "class" => held })
h["class"] << "!"
h[:datetime] << "Z"
p h, held
d = times[ARGV.size + 1]
a = [d.xmlschema, d.strftime("%H:%M:%S"), d.ctime, d.asctime]
a.each { |s| s << "." }
p a
