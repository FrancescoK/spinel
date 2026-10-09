# A Thread that reads a Symbol's name while another Thread grows the pool
# of Symbols made at run time still reads the name.
keep = ("ke" + "ep").to_sym
keep2 = ("ke" + "ep2").to_sym
stop = false
ready = [false, false]
readers = (0...2).map do |t|
  Thread.new do
    bad = 0
    ready[t] = true
    until stop
      bad += 1 unless keep.length == 4
      bad += 1 unless keep2.length == 5
    end
    bad
  end
end
sleep 0.001 until ready.all?
17_000.times { |i| ("w" + i.to_s).to_sym }
stop = true
p readers.map(&:value), keep, keep2
