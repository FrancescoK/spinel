# Family table of the order probe: ruby report.rb GENDIR LABEL [LABEL2 ..]
# A family is shape / victim and effect slots / effect kind (the route is
# folded in; the routes that fail are listed). Prints, per family with any
# non-ok case under any label, the count of non-ok cases per label.
gdir, *labels = ARGV
cases = {}
File.foreach(File.join(gdir, "cases.tsv")) do |l|
  id, shape, kind, fam, route, expr = l.chomp.split("\t", 6)
  cases[id.to_i] = { shape: shape, kind: kind, fam: fam.sub(%r{/$}, ""), route: route, expr: expr }
end
res = labels.to_h do |lb|
  h = {}
  File.foreach(File.join(gdir, "#{lb}.results.tsv")) { |l| id, st, = l.chomp.split("\t"); h[id.to_i] = st }
  [lb, h]
end
fams = Hash.new { |h, k| h[k] = { n: 0, bad: Hash.new(0), routes: Hash.new { |hh, kk| hh[kk] = [] } } }
cases.each do |id, c|
  # raise@j and order are kept apart; effect families fold the route
  f = fams[c[:fam]]
  f[:n] += 1
  labels.each do |lb|
    st = res[lb][id]
    next if st == "ok"
    f[:bad][lb] += 1
    f[:routes][lb] << c[:route]
  end
end
puts ["family", "cases", *labels.map { |l| "#{l} bad" }, "routes bad (#{labels[0]})"].join("\t")
tot = Hash.new(0)
fams.sort.each do |k, f|
  next if f[:bad].empty?
  labels.each { |lb| tot[lb] += f[:bad][lb] }
  puts [k, f[:n], *labels.map { |lb| f[:bad][lb] }, f[:routes][labels[0]].join(",")].join("\t")
end
puts ["TOTAL", cases.size, *labels.map { |lb| tot[lb] }, ""].join("\t")
