# frozen_string_literal: true
# A receiverless call past the call plan's list (seventy subclasses each
# answer label with a frozen literal, Plain by Base's cached String)
# hands on the handle: every method it can run publishes the handle or
# answers a literal with nothing between the pickup's reset and its
# return (#9258).
class Record
  attr_reader :text
  def initialize(text) = @text = text
end
class Base
  def label = (@label ||= +"plain:" << self.class.to_s)
  def title = label
  def record = Record.new(label)
  def record_by_title = Record.new(title)
  def same? = Record.new(label).text.equal?(label)
  def same_by_title? = Record.new(title).text.equal?(title)
end
class Plain < Base; end
class C0 < Base; def label = "gen-0"; end
class C1 < Base; def label = "gen-1"; end
class C2 < Base; def label = "gen-2"; end
class C3 < Base; def label = "gen-3"; end
class C4 < Base; def label = "gen-4"; end
class C5 < Base; def label = "gen-5"; end
class C6 < Base; def label = "gen-6"; end
class C7 < Base; def label = "gen-7"; end
class C8 < Base; def label = "gen-8"; end
class C9 < Base; def label = "gen-9"; end
class C10 < Base; def label = "gen-10"; end
class C11 < Base; def label = "gen-11"; end
class C12 < Base; def label = "gen-12"; end
class C13 < Base; def label = "gen-13"; end
class C14 < Base; def label = "gen-14"; end
class C15 < Base; def label = "gen-15"; end
class C16 < Base; def label = "gen-16"; end
class C17 < Base; def label = "gen-17"; end
class C18 < Base; def label = "gen-18"; end
class C19 < Base; def label = "gen-19"; end
class C20 < Base; def label = "gen-20"; end
class C21 < Base; def label = "gen-21"; end
class C22 < Base; def label = "gen-22"; end
class C23 < Base; def label = "gen-23"; end
class C24 < Base; def label = "gen-24"; end
class C25 < Base; def label = "gen-25"; end
class C26 < Base; def label = "gen-26"; end
class C27 < Base; def label = "gen-27"; end
class C28 < Base; def label = "gen-28"; end
class C29 < Base; def label = "gen-29"; end
class C30 < Base; def label = "gen-30"; end
class C31 < Base; def label = "gen-31"; end
class C32 < Base; def label = "gen-32"; end
class C33 < Base; def label = "gen-33"; end
class C34 < Base; def label = "gen-34"; end
class C35 < Base; def label = "gen-35"; end
class C36 < Base; def label = "gen-36"; end
class C37 < Base; def label = "gen-37"; end
class C38 < Base; def label = "gen-38"; end
class C39 < Base; def label = "gen-39"; end
class C40 < Base; def label = "gen-40"; end
class C41 < Base; def label = "gen-41"; end
class C42 < Base; def label = "gen-42"; end
class C43 < Base; def label = "gen-43"; end
class C44 < Base; def label = "gen-44"; end
class C45 < Base; def label = "gen-45"; end
class C46 < Base; def label = "gen-46"; end
class C47 < Base; def label = "gen-47"; end
class C48 < Base; def label = "gen-48"; end
class C49 < Base; def label = "gen-49"; end
class C50 < Base; def label = "gen-50"; end
class C51 < Base; def label = "gen-51"; end
class C52 < Base; def label = "gen-52"; end
class C53 < Base; def label = "gen-53"; end
class C54 < Base; def label = "gen-54"; end
class C55 < Base; def label = "gen-55"; end
class C56 < Base; def label = "gen-56"; end
class C57 < Base; def label = "gen-57"; end
class C58 < Base; def label = "gen-58"; end
class C59 < Base; def label = "gen-59"; end
class C60 < Base; def label = "gen-60"; end
class C61 < Base; def label = "gen-61"; end
class C62 < Base; def label = "gen-62"; end
class C63 < Base; def label = "gen-63"; end
class C64 < Base; def label = "gen-64"; end
class C65 < Base; def label = "gen-65"; end
class C66 < Base; def label = "gen-66"; end
class C67 < Base; def label = "gen-67"; end
class C68 < Base; def label = "gen-68"; end
class C69 < Base; def label = "gen-69"; end
items = [C0.new, C1.new, C2.new, C3.new, C4.new, C5.new, C6.new, C7.new, C8.new, C9.new, C10.new, C11.new, C12.new, C13.new, C14.new, C15.new, C16.new, C17.new, C18.new, C19.new, C20.new, C21.new, C22.new, C23.new, C24.new, C25.new, C26.new, C27.new, C28.new, C29.new, C30.new, C31.new, C32.new, C33.new, C34.new, C35.new, C36.new, C37.new, C38.new, C39.new, C40.new, C41.new, C42.new, C43.new, C44.new, C45.new, C46.new, C47.new, C48.new, C49.new, C50.new, C51.new, C52.new, C53.new, C54.new, C55.new, C56.new, C57.new, C58.new, C59.new, C60.new, C61.new, C62.new, C63.new, C64.new, C65.new, C66.new, C67.new, C68.new, C69.new, Plain.new]
c = items[ARGV.size + 70]
o = c.record
q = c.record_by_title
c.label << "!"
g = items[3].record
p o.text, q.text, c.label, g.text, c.same?, c.same_by_title?, items[3].same?
