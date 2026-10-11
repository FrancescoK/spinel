class LockTable
  def initialize
    @locks = Hash.new { |hash, key| hash[key] = Mutex.new }
    @plain = Mutex.new
  end

  def with_lock(name)
    lock = @locks[name]
    return lock.synchronize { yield } unless name.empty?

    @plain.synchronize { yield }
  end

  def describe(name) = with_lock(name) { { "name" => name } }
  def present?(name) = with_lock(name) { !name.start_with?("x") }
  def nothing(name) = with_lock(name) { nil }
  def count(name) = with_lock(name) { name.length * 10 }
  def label(name) = with_lock(name) { "lock #{name}" }
  def locked_inside?(name) = with_lock(name) { @locks[name].locked? }
end

table = LockTable.new
p table.describe("a")
p table.present?("a")
p table.present?("xa")
p table.nothing("a")
p table.count("abc")
p table.label("b")
p table.locked_inside?("c")
p table.describe("")
p table.count("")
p [table.count("ab") + 1, table.describe("z").fetch("name")]
