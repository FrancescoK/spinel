# A String stored into a global Hash and appended to through the Hash is the
# element itself; a global's Hash does not hold handles, so the append would be
# dropped: refused, as the same through a global Array is (#7834).
$fields = {}
$fields["a"] = +""
$fields["a"] << "x"
puts $fields["a"]
