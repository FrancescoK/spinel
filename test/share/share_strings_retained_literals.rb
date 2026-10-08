# A retained literal holds its String elements through the same boxed
# representation as a named container, including nested Arrays and Hashes.
def write_nested(table)
  table["row"]["key"] = "new"
end

table = {"row" => {"key" => "old"}}
write_nested(table)
p table

array = [["a", "b"], 0]
array[0][1, 1] = ["replacement"]
p array

integer_keys = [ {1 => "one"}, 0 ]
integer_keys[0][1] = "two"
p integer_keys

text = +"shared"
nested = [[text], 0]
alias_text = nested[0][0]
alias_text << "!"
p [nested, text]

# Read-only literal calls keep their ordinary representation and freezing.
p ["a", "b"].max
p({"key" => "value"}.freeze)
