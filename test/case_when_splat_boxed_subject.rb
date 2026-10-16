# `when *array` over a subject of more than one type: each element's ===
# answers false for a value of another class (a typed array's include was
# handed the box itself, a C type error). A case statement takes this path;
# a case whose value is used already matched through the box.
ROLES = %w[user assistant].freeze
NUMS = [1, 2].freeze
FLOATS = [1.5, 2.0].freeze

def kind(v)
  r = :other
  case v
  when *ROLES then r = :role
  when *NUMS then r = :num
  when *FLOATS then r = :float
  end
  r
end

p kind("user"), kind("x"), kind(1), kind(2.0), kind(1.0), kind(2), kind(1.5), kind(nil), kind(:user)
[{ "type" => "assistant" }, { "type" => 2 }, { "type" => 1.5 }].each { |ev| p kind(ev["type"]) }
