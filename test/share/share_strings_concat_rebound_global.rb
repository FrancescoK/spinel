# A concat keeps the global's old handle when its argument replaces it.
$concat = +"global"
original = $concat
original << "!"
result = $concat.concat(($concat = +"new"; "x"), "y" * 100)
p result, original, $concat
