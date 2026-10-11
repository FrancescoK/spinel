# A constant defined nowhere, read on a path that never runs, into a
# constant whose other writes give it one class (Racc's runtime core pick)
module Engine
  VERSION_R = "1.8"

  class Parser
    begin
      raise LoadError, "no extension" unless new.respond_to?(:_parse_c, true)
      Core_Version = Core_Version_C
      Runtime_Type = "c"
      Main_Routine = :_parse_c
    rescue LoadError
      Core_Version = VERSION_R
      Runtime_Type = "ruby"
      Main_Routine = :_parse_rb
    end
  end
end
p Engine::Parser::Core_Version
p Engine::Parser::Runtime_Type
p Engine::Parser::Main_Routine

# The read that does run raises NameError, into an Integer and a Float
class Limits
  begin
    MAX = Missing::MAX
  rescue NameError => e
    p e.class
    MAX = 10
  end

  begin
    RATIO = MISSING_RATIO
  rescue NameError => e
    p e.class
    RATIO = 0.5
  end
end
p Limits::MAX + 1
p Limits::RATIO * 2
