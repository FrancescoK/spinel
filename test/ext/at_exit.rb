# An ext-init library's at_exit hooks run when the host exits, as a required
# file's do in CRuby. The init used to run them as it returned, before any
# entry: the toplevel's hook printed first and was gone, and one an entry
# registered never ran at all.
at_exit { $stderr.puts "toplevel hook" }
module ExtAtExit
  #: (Integer) -> Integer
  def self.go(n)
    at_exit { $stderr.puts "entry hook #{n}" }
    $stderr.puts "entry #{n}"
    n + 1
  end
end
if __FILE__ == $0
  p ExtAtExit.go(1)
end
