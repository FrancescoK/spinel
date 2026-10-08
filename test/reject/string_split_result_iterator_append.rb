# String#split returns Strings whose storage is not yet shared with the Array
# when an iterator block mutates them in place.
# spinel: reject-share
a = " x , y ".split(",")
a.each { |s| s.strip! }
p a
