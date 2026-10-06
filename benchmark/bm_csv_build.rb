# Builds CSV lines field by field in a helper that appends to the caller's
# buffer, keeps each finished line in an Array, then decorates every kept
# line in place: the String a method builds and the one a container holds
# are the same object.
def add_field(line, value, first)
  line << "," unless first
  if value.include?(",") || value.include?("\"")
    line << "\"" << value.gsub("\"", "\"\"") << "\""
  else
    line << value
  end
  line
end

def build_row(fields)
  line = +""
  fields.each_with_index { |f, i| add_field(line, f, i == 0) }
  line
end

names = %w[alpha beta gamma delta epsilon zeta eta theta]
rows = []
i = 0
while i < 400_000
  fields = [names[i % 8], (i * 7).to_s, "note #{i % 13}, ok", names[(i + 3) % 8] * 2, "q\"#{i % 5}"]
  rows << build_row(fields)
  i += 1
end
rows.each { |r| r << "\n" }
total = 0
rows.each { |r| total += r.bytesize }
puts rows.size
puts total
print rows[12345]
