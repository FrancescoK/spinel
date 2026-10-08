# Flag-only: stored conditional values retain the selected String's handle.
# Later mutations through another name must be visible in every container.
s = +"s"
t = +"t"
mapped = [1, 2].map { |i| i == 1 ? (s.strip! || s) : t }
collected = [1, 2].collect { |i| case i; when 1 then s; else t; end }
stored = [1, 2].each_with_object([]) { |i, out|
  out << (unless i == 1; t; else s; end)
}
replaced = [s, t].map! { |x| x.strip! || x }
nexts = [1, 2].map { |i| next (i == 1 ? s : t) }
short = [s.strip! && s, s.strip! || t]
s << "!"
t << "?"
p mapped, collected, stored, replaced, nexts, short
# Fresh arms still allocate their own String and only the chosen arm runs.
p [1, 2].map { |i| case i; when 1 then s; else +"fresh"; end }
p [s, t].map! { |x| if x.empty?; t; else; x; end }
p [s, t].collect! { |x| unless x.empty?; x; else; s; end }
# An arm can itself hand on the String through a call's block value.
routes = [s, t].map! { |x| if x.empty?; t; else; x.then { |v| v }; end }
s << "+"
t << "-"
p routes
# A demanded scalar conversion still creates a fresh handle in its arm.
fresh = [1, 2].map { |i| case i; when 1 then s; else i.to_s; end }
fresh[1] << "fresh"
p fresh, s
