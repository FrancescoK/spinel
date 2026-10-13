# A parameter subject may be the caller's String under another name, but a
# block that changes no String but its own matches cannot change it.
def words(s)
  kept = []
  s.scan(/\w+/) { |w| kept << w; w << "?" }
  kept
end
p words(+"hi yo")
