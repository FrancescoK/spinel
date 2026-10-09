# A parameter subject may be the caller's String under another name, so the
# refusal stays.
def words(s)
  kept = []
  s.scan(/\w+/) { |w| kept << w; w << "?" }
  kept
end
p words(+"hi yo")
