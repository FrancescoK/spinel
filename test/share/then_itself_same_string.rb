# itself of a block parameter answers the String handed to the block (#9258)
x = +"h"
x << "!"
p x.then { |q| q.itself }.equal?(x)
w = x.then { |q| q.itself }
w << "?"
p x
