# ENV.update / merge! / replace with something that is no Hash raise CRuby's
# TypeError, which spells nil, true and false as themselves.
p((ENV.update(nil) rescue $!))
p((ENV.merge!(true) rescue $!))
p((ENV.replace(false) rescue $!))
p((ENV.update(5) rescue $!))
p((ENV.update("x") rescue $!))
