# A chain of String bangs under safe navigation on a variable changes the
# variable's String, which every name of it sees.
v = +"ab"
v2 = v
v&.upcase!.downcase!.capitalize!
p v, v2
@w = +"cd"
@w&.upcase!.concat("1")
p @w
