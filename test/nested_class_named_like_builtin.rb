# A user class nested in a module under a builtin's name (`M::File`,
# `Badline::KernalTrap::File`) must not take over the rooted spelling of the
# builtin: `::File` names the top-level File everywhere, while a bare `File`
# inside the module still names the nested class.
require "tmpdir"

module M
  class File
    def self.label = "M::File"
  end

  class Time
    def self.label = "M::Time"
  end

  def self.bare = File.label
  def self.rooted(path) = ::File.exist?(path)
  def self.bare_time = Time.label
  def self.rooted_time = ::Time.at(0).utc.year
end

module Other
  def self.rooted(path) = ::File.basename(path)
end

path = ::File.join(Dir.tmpdir, "spinel_nested_builtin_#{Process.pid}.txt")
::File.binwrite(path, "a")
p ::File.writable?(path)
p File.exist?(path)
p ::File.read(path)
p M.bare
p M.rooted(path)
p M::File.label
p Other.rooted("a/b.rb")
::File.delete(path)
p ::File.exist?(path)

p M.bare_time
p M.rooted_time
p ::Time.at(0).utc.year
p Time.at(0).utc.year
p M::Time.label
