# A reopened Object's constants are the top-level ones: Object.const_get
# with a name known only at run time finds a top-level class, and a missing
# name's NameError is unqualified, as in CRuby (#9468).
module Helpers
  def helper_answer = 7
end

class FooJob
  def self.perform = "ran"
end

class Object
  include Helpers
  INSIDE = "inside"
  def zzz = 1
end

names = { "job" => "FooJob", "inside" => "INSIDE", "ghost" => "GhostJob" }
p Object.const_get(names["job"]).perform
p Object.const_get(names["inside"])
p Object.const_defined?(names["job"]), Object.const_defined?(names["ghost"])
begin
  Object.const_get(names["ghost"])
rescue NameError => e
  p e.message
end
begin
  Object.const_get("GhostJob")
rescue NameError => e
  p e.message
end
p zzz, helper_answer
