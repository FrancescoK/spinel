# A global read before its first write is nil, also when the read is in a
# method the program reaches through an alias. Whether something can read
# a global before it is written is asked of the calls of the load phase:
# a call may reach a method of the program by any name the program
# defines one by. Those names were taken from the method table, which has
# no entry for an alias (the class keeps it as a name to resolve), so a
# call through `alias` or `alias_method` was taken to reach none of the
# program's methods: the global counted as written first, its slot took
# no nil, and the read printed 0.0. The load record's names have the
# aliases.

def top_read = $top
alias top_alias top_read
p top_alias
$top = 1.5
p top_alias

class Reader
  def read = $kept
  alias aliased read
end
p Reader.new.aliased
$kept = 2.5
p Reader.new.aliased

class Later
  def read = $later
end
class Later
  alias_method :renamed, :read
end
p Later.new.renamed
$later = 3.5
p Later.new.renamed
