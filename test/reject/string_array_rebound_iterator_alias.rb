# Rebinding a block-local alias after appending must not hide the earlier
# mutation of the Array's element.
a = [+"r"]
a.each { |x| t = x; t << "!"; t = +"s" }
p a
