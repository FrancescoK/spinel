# table.rb [probe names...]: one line per probe: CRuby-match per build and mode,
# flags rows where branch differs from master or pre.
D = File.join(__dir__, "out")
names = ARGV.empty? ? Dir.children(D).sort : ARGV
names.each do |n|
  dir = File.join(D, n)
  next unless File.exist?(File.join(dir, "cruby.txt"))
  cr = File.read(File.join(dir, "cruby.txt"))
  cells = {}
  %w[pre master branch].each do |b|
    %w[inline graph promote].each do |m|
      f = File.join(dir, "#{b}-#{m}.txt")
      cells["#{b}-#{m}"] = File.exist?(f) ? File.read(f) : nil
    end
  end
  gc = File.join(dir, "branch-gc.txt")
  gcs = File.exist?(gc) ? (File.read(gc) == cells["branch-inline"] ? "gc=" : "GC-DIFF") : ""
  groups = {}
  sym = lambda do |s|
    next "-" if s.nil?
    next "ok" if s == cr
    groups[s] ||= "W#{groups.size + 1}"
  end
  row = cells.map { |k, v| [k, sym.(v)] }.to_h
  flag = %w[inline graph promote].any? { |m| row["branch-#{m}"] != row["master-#{m}"] } ? " *vs-master" : ""
  flag += %w[inline graph promote].any? { |m| row["branch-#{m}"] != row["pre-#{m}"] } ? " *vs-pre" : ""
  modes_differ = %w[pre master branch].any? { |b| [row["#{b}-inline"], row["#{b}-graph"], row["#{b}-promote"]].uniq.size > 1 } ? " MODES" : ""
  short = %w[pre master branch].map { |b| "#{b}=" + %w[inline graph promote].map { |m| row["#{b}-#{m}"] }.join("/") }.join(" ")
  puts "#{n.ljust(34)} #{short} #{gcs}#{flag}#{modes_differ}"
end
