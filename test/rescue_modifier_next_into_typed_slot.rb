# `x = expr rescue next`, or a fallback that ends in `next`, where x holds
# one class: the jump leaves before x is written, and compiles.
def dirs(names)
  out = []
  names.each do |name|
    stat = File.stat(name) rescue next
    out << name if stat.directory?
  end
  out
end

p dirs(["/", "/no/such/path", "/tmp"])

def first_dir(paths)
  paths.each do |path|
    stat = File.stat(path) rescue next
    return path if stat.directory?
  end
  nil
end

p first_dir(["/no/such", "/"])

def counted(names)
  skipped = 0
  out = []
  names.each do |name|
    stat = File.stat(name) rescue (skipped += 1; next)
    out << name if stat.directory?
  end
  [out, skipped]
end

p counted(["/", "/no/such", "/tmp", "/nope"])
