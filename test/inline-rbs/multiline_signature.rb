# A method type spread over several lines with `#|` continuations, as
# ruby/rbs's inline syntax writes a long signature (herb, which Action View
# loads, writes its node methods so). The lines join into one signature,
# which pins the same slots as the one-line form: each annotation pins a
# slot to `untyped`, which inference would not choose on its own, so the C
# shows whether it applied, and the program compiled with `--no-inline-rbs
# --rbs sig/multiline_signature` produces the same C byte for byte.
class Report
  #: (
  #|   untyped,
  #|   untyped
  #| ) -> untyped
  def total(rows, title)
    "#{title}: #{rows.sum}"
  end

  #: (untyped,
  #|  untyped) -> untyped
  def span(a, b) = b - a
end

r = Report.new
p r.total([1, 2], "t"), r.span(3, 10)
