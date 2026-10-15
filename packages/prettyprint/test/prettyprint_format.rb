# prettyprint is CRuby's own file: a group that fits stays on one line, one
# that does not breaks at its breakables, nested groups break outside in.
require "prettyprint"

def list(q, items)
  q.group(1, "[", "]") do
    items.each_with_index do |item, i|
      if i > 0
        q.text ","
        q.breakable
      end
      q.text item
    end
  end
end

puts PrettyPrint.format(String.new, 30) { |q| list(q, %w[a b c]) }
puts PrettyPrint.format(String.new, 30) { |q| list(q, %w[alpha beta gamma delta epsilon]) }
out = PrettyPrint.format(String.new, 20) do |q|
  q.group(2, "call(", ")") do
    q.breakable ""
    q.text "first_argument"
    q.text ","
    q.breakable
    q.nest(2) { q.text "second" }
  end
end
puts out
puts PrettyPrint.singleline_format(String.new) { |q| list(q, %w[x y]) }
