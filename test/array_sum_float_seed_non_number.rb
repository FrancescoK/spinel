# Array#sum with a Float seed over a boxed (mixed) array folds through the
# seeded sum, as a boxed receiver's does: an element that is no number raises
# the seed's TypeError, as CRuby does. Adding the seed to a plain fold of the
# Integer and Float elements skipped any other element and answered a number.
def t
  p yield
rescue TypeError => e
  puts "#{e.class}: #{e.message}"
end

t { [0.1, "a"].sum(0.0) }
t { [1, nil].sum(0.0) }
t { [0.5, :sym].sum(1.5) }
t { [1, 2].sum(0.5) }
t { [1, 2.5].sum(0.5) }
t { [].sum(1.5) }
