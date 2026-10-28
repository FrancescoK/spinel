# B#get is defined again by a later reopening of B, and S overrides it in a
# reopening between them: the call on an S before S's own def reaches B's
# earlier get, as in CRuby (1, then 5). It was refused.
class B
  def get = 1
end
class S < B
end
p S.new.get
class S
  def get = 5
end
class B
  def get = 2
end
p S.new.get
