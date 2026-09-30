sel = [3, 1, 2].select
p sel.each { |x| x > 1 }
p sel.each { |x| x < 3 }
fnd = [3, 1, 2].find
p fnd.each { |x| x < 3 }
mp = [3, 1, 2].map
p mp.each { |x| x * 2 }
rej = [3, 1, 2].reject
p rej.each { |x| x > 1 }
srt = [3, 1, 2].sort_by
p srt.each { |x| -x }
grp = [3, 1, 2].group_by
p grp.each(&:odd?)
mnb = [3, 1, 2].min_by
p mnb.each { |x| -x }
mxb = [3, 1, 2].max_by
p mxb.each { |x| -x }
mmb = [3, 1, 2].minmax_by
p mmb.each { |x| -x }
flm = [3, 1, 2].flat_map
p flm.each { |x| [x, x] }
fmp = [3, 1, 2].filter_map
p fmp.each { |x| x * 10 if x > 1 }
prt = [3, 1, 2].partition
p prt.each { |x| x > 1 }
tkw = [3, 1, 2].take_while
p tkw.each { |x| x > 1 }
dpw = [3, 1, 2].drop_while
p dpw.each { |x| x > 1 }
fdi = [3, 1, 2].find_index
p fdi.each { |x| x == 2 }

rsel = (1..5).select
p rsel.each { |x| x.even? }
rfnd = (1..5).detect
p rfnd.each { |x| x > 3 }
hsel = {a: 3, b: 1, c: 2}.select
p hsel.each { |k, v| v > 1 }
hrej = {a: 3, b: 1, c: 2}.reject
p hrej.each { |k, v| v > 1 }
hmap = {a: 3, b: 1}.map
p hmap.each { |k, v| "#{k}=#{v}" }
hmin = {a: 3, b: 1, c: 2}.min_by
p hmin.each { |k, v| v }

src = [1, 2, 3]
live = src.select
src << 4
p live.each { |x| x > 1 }
p live.next

[10].each do |k|
  inner = [k, k + 1].map
  p inner.each { |x| x * 2 }
end

visit = [1, 2, 3].find
visit.each { |x| puts "visit #{x}"; x == 2 }
brk = [5, 6, 7].map
p brk.each { |x| break x * 100 if x == 6; x }

def collect_odd(xs)
  st = xs.filter_map
  st.each { |x| x * 3 if x.odd? }
end
p collect_odd([1, 2, 3])
p collect_odd([4, 5])
