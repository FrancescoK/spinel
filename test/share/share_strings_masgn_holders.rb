# Multiple assignment keeps the shared String each holder hands it.
class AssignmentStrings
  attr_accessor :value
  Pair = Struct.new(:value)
  TEXT = "frozen"

  def run
    $assignment_string = +"global"
    a, unused = $assignment_string, 1
    $assignment_string << "!"
    p [a, $assignment_string, a.equal?($assignment_string)]

    @text = +"instance"
    b, unused = @text, 2
    b.insert(0, "!")
    p [@text, b, @text.size == b.size]

    @@text = +"class"
    c, unused = @@text, 3
    c.upcase!
    p [@@text, c, @@text.object_id == c.object_id]

    d, unused = TEXT, 4
    p [d.equal?(TEXT), d.frozen?]
    begin
      d << "!"
    rescue FrozenError
      puts "frozen"
    end

    self.value = +"attribute"
    e, unused = self.value, 5
    e << "!"
    p [self.value, e, self.value.equal?(e)]

    pair = Pair.new(+"member")
    f, unused = pair.value, 6
    f << "!"
    p [pair.value, f, pair.value.equal?(f)]

    array = [+"element"]
    g, unused = array[0], 7
    g << "!"
    p [array[0], g, array[0].equal?(g)]

    hash = {key: +"entry"}
    h, unused = hash[:key], 8
    h << "!"
    p [hash[:key], h, hash[:key].equal?(h)]

    i, unused = +@text, 9
    i << "?"
    p [@text, i, @text.equal?(i)]
  end
end
AssignmentStrings.new.run
