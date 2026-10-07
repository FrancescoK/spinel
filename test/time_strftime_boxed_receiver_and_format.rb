# strftime on a Time read out of a container (a boxed value) with a format
# whose class is known only at run time (webrick's AccessLog formats
# `params["t"].strftime(param || CLF_TIME_FORMAT)`, where param also takes
# other values): a String formats, anything else raises CRuby's TypeError
def pick(i) = i == 0 ? "%Y-%m" : (i == 1 ? 7 : nil)
t = Time.at(0).utc
v = [t, 1][0]
p v.strftime(pick(0))
p v.strftime(pick(2) || "[%d/%b/%Y]")
begin
  v.strftime(pick(1))
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
fmt = String.new("%H:")
fmt << "%M"
p v.strftime([fmt, 1][0])
begin
  [1, t][0].strftime(pick(0))
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
