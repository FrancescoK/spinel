# A fresh String stored where the rule shares the container's elements is
# built as a String and wrapped at the store, also when the receiver runs
# first (an ivar's Array at the top level).
@a = []
@a << +"x"
@a.each { |x| x << "!" }
p @a
