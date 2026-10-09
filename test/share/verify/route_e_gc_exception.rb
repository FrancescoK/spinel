msg = +"m"
alias_m = msg
caught = []
20.times do |i|
  begin
    alias_m << i.to_s
    raise ArgumentError, msg if i.odd?
    junk = Array.new(10) { "j" * i }
  rescue ArgumentError => e
    caught << e.message
  end
end
p caught.size, caught.last, msg.size
