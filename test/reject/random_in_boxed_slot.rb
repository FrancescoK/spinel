# A Random has no boxed form: stored in an Array beside an Integer it was
# boxed as nil, so `.class` answered NilClass and `rand` raised for nil.
# Spinel refuses the program instead.
y = [Random.new(1), 1][0]
p y.class
