# spinel: rbs-seed-check
module M
  def self.table
    @table ||= {}
  end
end

module N
  def self.table
    @table = {} if @table.nil?
    @table
  end
end

M.table["a"] = "1"
puts "size " + M.table.length.to_s
N.table["b"] = "2"
puts "read " + N.table["b"]
