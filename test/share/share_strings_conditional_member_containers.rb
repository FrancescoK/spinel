# Conditional attribute writes connect their value to the actual member,
# including their value form and a method that returns a String Array.
class ConditionalContainer
  attr_accessor :items
end

def fresh_items = ["made"]
ConditionalContainer.new.items = ["seed"]
first = ConditionalContainer.new
first.items ||= fresh_items
p first.items
second = ConditionalContainer.new
value = (second.items ||= ["value"])
p value
p(second.items ||= ["ignored"])
second.items &&= ["replaced"]
p second.items

third = ConditionalContainer.new
text = +"shared"
third.items ||= [text]
text << "!"
p third.items
third.items[0] << "?"
p text

PairContainer = Struct.new(:items)
pair = PairContainer.new
pair.items ||= ["pair"]
p pair.items
