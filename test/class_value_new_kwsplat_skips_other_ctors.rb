class Image
  def initialize(path, read_only: false)
    @path = path
    @read_only = read_only
  end

  def describe = "#{@path} read_only=#{@read_only}"
end

class Archive
  def initialize(path)
    @path = path
  end

  def describe = "#{@path} archive"
end

class Counter
  def initialize(items, start: 0)
    @items = items
    @start = start
  end

  def describe = "#{@items.size} from #{@start}"
end

TYPES = { ".img" => Image, ".arc" => Archive }.freeze

def open_storage(path, disk)
  storage = TYPES[File.extname(path)]
  storage == Archive ? storage.new(path) : storage.new(path, **disk)
end

puts Counter.new([1, 2], start: 3).describe
puts open_storage("a.img", { read_only: true }).describe
puts open_storage("b.arc", {}).describe
