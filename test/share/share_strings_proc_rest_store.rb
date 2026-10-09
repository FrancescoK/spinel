# spinel: gc-minor
# A proc rest stores each incoming String according to its element share fact.
kept = []
store = proc { |*values| kept << values[0] }
store.call(+"rest")
store.call(2)
kept[0] << "!"
p kept
source = +"source"
store.call(source)
kept[2] << "?"
p [source, kept[2], source.equal?(kept[2])]
store.call("same")
store.call("same")
p kept[3].equal?(kept[4])
begin
  kept[3] << "!"
rescue FrozenError
  puts "frozen"
end
p kept[3]
