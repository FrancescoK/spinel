# Raising through a constant that aliases a class raises that class, which a
# rescue of its ancestor catches (Thor's AmbiguousTaskError = AmbiguousCommandError).
module Thor
  class Error < StandardError; end
  class AmbiguousCommandError < Error; end
  AmbiguousTaskError = AmbiguousCommandError
end
begin
  raise Thor::AmbiguousTaskError, "ambiguous"
rescue Thor::Error => e
  p [e.class, e.message, Thor::AmbiguousTaskError == Thor::AmbiguousCommandError]
end
begin
  raise Thor::AmbiguousCommandError, "direct"
rescue Thor::AmbiguousTaskError => e
  p [e.class, e.message]
end
