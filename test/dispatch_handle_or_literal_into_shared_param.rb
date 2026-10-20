# A receiverless call in a base class whose own method answers its slot's
# shared String, beside a subclass's answering a String literal, handed on
# as a method's argument: the call takes the handle the base class's
# method publishes, and the literal's own where the subclass answers.
class Note
  attr_reader :line, :tag_name, :message, :status
  def initialize(line, tag_name, message, status)
    @line = line
    @tag_name = tag_name
    @message = message
    @status = status
  end
end
module Rules
  class Base
    def self.tag_name
      parts = name.split("::")
      "#{parts[-2]}/#{parts[-1]}"
    end
    def tag_name
      return @tag_name if @tag_name

      @tag_name = self.class.tag_name
    end
    def enabled?(n) = CONF.key?(tag_name) && n > 0
    def add_note(n, message: nil)
      @notes ||= []
      msg = message || "msg #{n}"
      status = enabled?(n) ? :unsupported : :disabled
      @notes << Note.new(n, tag_name, msg, status)
      nil
    end
    def notes = @notes
  end
end
NAMES = {}
CONF = { "Rules/Base" => 1, "Group/SectionName" => 2 }
module Rules
  class Leaf < Base
    def tag_name = "Group/SectionName"
  end
end
bs = Rules::Base.new
d = Rules::Leaf.new
[bs, d].each { |o| o.add_note(1); o.add_note(2, message: "m") }
other = Note.new(0, +"buf", "x", :s)
other.tag_name << "!"
p bs.notes.map(&:tag_name), d.notes.map(&:tag_name), d.notes.map(&:status)
p bs.notes[0].tag_name.equal?(bs.notes[1].tag_name), d.notes[0].tag_name.equal?(d.notes[1].tag_name)
p other.tag_name, Note.new(1, 7, nil, nil).tag_name
