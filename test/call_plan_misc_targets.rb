# Mixed IO answers and boxed copy overrides keep their inference records.
require "tmpdir"
class IO
  def plan_kind = 1
end
class File
  def plan_kind = :file
end
Dir.mktmpdir("call-plan") do |dir|
  path = File.join(dir, "input")
  File.write(path, "hi")
  File.open(path) do |file|
    p file.plan_kind, $stdout.plan_kind
    [file, $stdout].each { |io| p io.plan_kind }
  end
end
class PlanCopy
  def dup = :duplicate
  def clone = :clone
end
[PlanCopy.new, [1]].each { |value| p value.dup, value.clone }
