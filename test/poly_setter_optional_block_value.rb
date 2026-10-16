require "tmpdir"

class Entry
  def inode
    @inode
  end

  def inode=(value)
    @inode = value
  end
end

class Source
  def inode
    @inode
  end

  def inode=(value)
    @inode = value
  end
end

def record(entry, stat, path)
  File.open(path, "rb") do |file|
    entry.inode = stat.ino
  end
end

def assign(entry, value, path)
  File.open(path, "rb") do |file|
    entry.inode = value
  end
end

def assign_direct(entry, value)
  entry.inode = value
end

path = File.join(Dir.tmpdir, "spinel-poly-setter-#{Process.pid}")
begin
  File.write(path, "data")
  stat = File.stat(path)
  entry = Entry.new
  source = Source.new
  record(entry, stat, path)
  record(source, stat, path)
  puts entry.inode == stat.ino && source.inode == stat.ino
  p assign(entry, nil, path)
  p assign(source, 7, path)
  p entry.inode
  p source.inode
  p assign_direct(entry, 3)
  p assign_direct(source, nil)
ensure
  File.unlink(path)
end
