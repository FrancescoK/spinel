# dig on a yield receiver: always poly, regardless of receiver kind or how
# many indices the call passes (K-024 leftover scope, kilau docs/CATALOG.md).
def dug1 = yield.dig(0)
p dug1 { [1, 2] }
p dug1 { ["a", "b"] }

def dug2 = yield.dig(0, 1)
p dug2 { [[1, 2], [3, 4]] }
p dug2 { [{ "a" => 1 }] }
