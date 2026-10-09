h = {}
@k = +"key"
alias_k = @k
200.times do |i|
  h[@k] = i
  h.key?(@k)
  h.fetch(@k, nil)
  alias_k << "x" if i % 50 == 0
  junk = "#{i}" * 10
end
p h.size, h.keys.map(&:size).sort, h[@k]
