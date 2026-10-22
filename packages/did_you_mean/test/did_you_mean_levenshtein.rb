# DidYouMean::Levenshtein.distance: how many characters to insert, delete
# or replace to turn one String into the other.
require "did_you_mean"

def distance(a, b) = p DidYouMean::Levenshtein.distance(a, b)

distance("kitten", "sitting")
distance("", "abc")
distance("abc", "")
distance("", "")
distance("same", "same")
distance("ab", "ba")
distance("Foo", "foo")
distance("flaw", "lawn")
distance("first_name_change!", "first_name_change")
distance("héllo", "hello")
distance("連勝文", "連勝丼")
