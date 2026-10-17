# dig on a yield receiver: one index answers the array's element (the same
# nilable getter `[]` uses), two or more answer poly (a second level of
# navigation is not guaranteed to stay a plain scalar) -- see
# ty_recv_builtin_result's dig arm in src/types.c.
def dug1 = yield.dig(0)
p dug1 { [1, 2] }
p dug1 { ["a", "b"] }

# dug2's two sites are Array-of-Array and Array-of-Hash, neither a plain
# array, so this does not exercise the argc >= 2 arm above (both sites
# already answer poly through the ordinary, non-per-site path); it only
# pins that a two-level dig keeps working at all when nested under a yield.
def dug2 = yield.dig(0, 1)
p dug2 { [[1, 2], [3, 4]] }
p dug2 { [{ "a" => 1 }] }
