# An empty String field is quoted by default (`quote_empty: true`, CRuby's
# default), so `["", nil, 1.0]` writes `"",,1.0` — the empty String as `""`,
# the nil as nothing. `quote_empty: false` leaves the empty String bare, and
# `force_quotes: true` quotes nil too. A generated line reads back to the same
# fields.
require "csv"
require "tmpdir"

p CSV.generate_line(["", nil, 1.0])
p CSV.generate_line(["", nil, 1.0], quote_empty: false)
p CSV.generate_line(["a", "", "b"])
p CSV.generate_line(["", "x"], quote_empty: false)
p CSV.generate_line([" ", ""])
p CSV.generate_line([0, "", false, nil])
p CSV.generate_line([nil])
p CSV.generate_line([])
p CSV.generate_line([""])
p CSV.generate_line([nil], force_quotes: true)
p CSV.generate_line(["a", nil, ""], force_quotes: true)
p CSV.generate_line(["a", "b"], force_quotes: true)

p CSV.generate { |csv| csv << ["", nil] }
p CSV.generate(quote_empty: false) { |csv| csv << ["", nil] }

p CSV.parse_line(CSV.generate_line(["", nil, 1.0]))
p CSV.parse(CSV.generate { |csv| csv << ["", nil] << ["a", ""] })

# A file-backed writer carries `quote_empty` too: the empty String is written
# bare, so the file holds just the record separator.
path = File.join(Dir.tmpdir, "sp_csv_quote_empty_#{Process.pid}.csv")
begin
  CSV.open(path, "w", quote_empty: false) { |csv| csv << [""] }
  p File.read(path)
ensure
  File.delete(path) if File.exist?(path)
end
