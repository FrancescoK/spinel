# Regression (#1827, follow-up to #1819): a local Array[String] parked in a
# nil-at-boot class ivar and returned is inferred as a poly array, but an
# `-> Array[String]` RBS pin is a correct, CRuby-verifiable promise. Honor it:
# materialize the typed array at the return boundary (sp_StrArray_from_poly_array)
# instead of rejecting the annotation or returning a poly array through a
# StrArray* slot (which SIGSEGV'd). The returned element must be genuinely
# String-typed, so `=~` and `.upcase` on it must work.
# spinel: rbs-seed-check
class Db
  def self.capture
    log = []
    @log = log
    @log.push("SELECT 1 WHERE article_id = 5") unless @log.nil?
    log
  end
end

rows = Db.capture
puts(rows[0] =~ /article_id/ ? "match" : "no match")
puts rows[0].upcase
puts rows.length
