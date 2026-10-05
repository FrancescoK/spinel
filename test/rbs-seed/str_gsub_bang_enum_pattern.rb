# gsub!(pattern) with no replacement and no block answers an Enumerator.
# On a receiver an RBS signature types String? (gsub_bang_recv), the
# value-form bang arm took such a call with a pattern of a class the
# Enumerator arm does not take (an Array) and answered the String its plain
# form gives, which went into the call's Enumerator slot and did not build.
# The call now raises as it does on a receiver no signature types, where
# CRuby answers an Enumerator that raises TypeError only when it runs (a
# separate difference, so the check reads only that it built), and a String
# pattern still answers the Enumerator.
def gsub_bang_recv(x) = x

def t(k)
  r = gsub_bang_recv(k == 0 ? +"ab" : nil)
  e = r.gsub!("a")
  p e.class
  a0 = [7]
  begin
    x = r.gsub!(a0)
  rescue NoMethodError
  end
  p :built
end

t(ARGV.size)
