# Hash#fetch on a Hash held boxed, with a default that is an Integer or
# nil (`form == :utc ? 0 : nil`): the default is handed to the dispatch
# boxed, and the result it seeds starts as that box, not as an Integer
# boxed again.
def pick(parts, form)
  parts.fetch(:offset, form == :utc ? 0 : nil)
end

h = [{ offset: 3600 }, { year: 2012 }].sample
p pick({ offset: 3600 }, :utc)
p pick({ year: 2012 }, :utc)
p pick({ year: 2012 }, :local)
p pick({ offset: 7 }, :local)
p pick(h, :utc).is_a?(Integer)
