# A module method mixed into an includer and fed two statically distinct
# hash types (an --rbs StrStr pin and symbol-keyed literals) plus itself
# recursively. A SHARED transplanted body carried one node-type cache
# across includers, so the emitted signature and the body's reads could
# disagree (StrStrHash param vs poly receiver init, void return through
# the recursion). Per-includer cloning keeps each copy self-consistent.
# spinel: rbs-seed-check
module Harness
  def stringify_keys(hash)
    out = {}
    hash.each do |k, v|
      if v.is_a?(Hash) then out[k.to_s] = stringify_keys(v)
      else out[k.to_s] = v end
    end
    out
  end
end
class Router
  def path_params = { "id" => "5" }
end
class TestCase
  include Harness
  def run
    merged = stringify_keys(Router.new.path_params)
    { article: { title: "t" } }.each do |k, v|
      if v.is_a?(Hash) then merged[k.to_s] = stringify_keys(v)
      else merged[k.to_s] = v end
    end
    merged.length
  end
end
puts TestCase.new.run
