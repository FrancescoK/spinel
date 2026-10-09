# Matching String separators keep their identity; all other pieces are new.
s = +"a-b"
sep = +"-"
a = s.partition(sep)
a[0] << "!"
a[1] << "?"
a[2] << "#"
p [s, sep, a]
s = +"a-b"
sep = +"="
a = s.partition(sep)
a[0] << "!"
a[1] << "?"
p [s, sep, a]
s = +"a-b-c"
sep = +"-"
a = s.rpartition(sep)
a[1] << "!"
p [s, sep, a]
s = +"ab"
sep = +""
a = s.partition(sep)
a[1] << "!"
p [s, sep, a]

$calls = 0
def partition_subject
  $calls += 1
  +"a-b"
end
def partition_separator(s)
  $calls += 10
  s
end
sep = +"-"
a = partition_subject.partition(partition_separator(sep))
a[1] << "!"
p [$calls, sep, a]
s = +"a-b"
a = s.partition(/-/)
a[0] << "!"
p [s, a]
