# filter_map's answer, an Array of one class's instances, takes every Array
# method: a caller rejects and selects over a list method, which
# filter_maps command output lines onto Struct rows. The answer leaves the inlined
# filter_map through the call's value; it stays the general Array unless
# the caller's own uses allow the narrow one.
class Tmux
  Info = Struct.new(:name, :attached, :keep, :idle, keyword_init: true)

  def list
    "a/x 1 0 5\nb/y 0 0 9\nplain\nc/z 0 1 20\nd/w 0 0 2\n".each_line.filter_map do |line|
      name, att, keep, idle = line.split
      next if idle.nil?

      Info.new(name: name, attached: att == "1", keep: keep == "1", idle: idle.to_i)
    end
  end
end

class Reaper
  def initialize(tmux) = @tmux = tmux

  def stale
    @tmux.list
         .reject { |s| s.attached || s.keep }
         .select { |s| s.idle && s.idle >= 3 }
  end

  def excess(max)
    live = @tmux.list
    live.reject { |s| s.attached || s.keep }.sort_by { |s| -s.idle }.first(live.size - max)
  end
end

r = Reaper.new(Tmux.new)
p r.stale.map(&:name)
p r.excess(3).map(&:name)
rows = Tmux.new.list
p rows.group_by { |i| i.name[0] }.keys
p rows.reverse.map(&:name), rows.last(2).size, (rows + rows).size
p rows.sum(&:idle), rows.uniq(&:keep).size, rows.each_slice(2).to_a.size
p rows.size
