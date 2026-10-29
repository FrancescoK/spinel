# A top-level detect / collect_concat answers a receiverless call of it,
# at the top level and inside a class's methods, though detect and
# collect_concat are find and flat_map under another name for an
# Enumerable.
def detect = :top_detect
def collect_concat = :top_collect_concat
class K
  def go = [detect, collect_concat]
  def self.go = detect
end
p detect
p collect_concat
p K.new.go
p K.go
