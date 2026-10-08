# Strings pushed into an Array the Hash hands out (`h[k] << s`, as WEBrick's
# parse_header builds its header) and then mutated in place through an
# iteration of the Hash's values: the walk that makes those Strings shared
# handles followed only the stores into the Hash itself (its literal and
# `h[k] = []`), not the pushes into the Arrays it holds, so strip! changed a
# copy and the header kept its leading space.
def parse_header(raw)
  header = Hash.new([].freeze)
  field = nil
  raw.each_line { |line|
    case line
    when /^([A-Za-z0-9\-]+):([^\r\n\0]*?)\r\n\z/m
      field, value = $1, $2
      field.downcase!
      header[field] = [] unless header.has_key?(field)
      header[field] << value
    when /^[ \t]+([^\r\n\0]*?)\r\n/m
      header[field][-1] << " " << $1
    end
  }
  header.each { |key, values| values.each(&:strip!) }
  header
end

h = parse_header("Content-Length: 12\r\nX-A:  a\r\n  b\r\nX-A: c \r\n")
p h
p h["content-length"][0]
p Integer(h["content-length"][0])

tags = {}
%w[a b a].each { |k| (tags[k] ||= []) << +" #{k} " }
tags.each_value { |vs| vs.each(&:strip!) }
p tags
