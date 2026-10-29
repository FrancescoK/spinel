# Aliases retain the definition live at their statements.
module AliasLayer
  def speak = "L " + super
end
class AliasVoice
  def speak = "d"
  alias talk speak
  alias_method :chat, :speak
end
d = AliasVoice.new
p d.talk, d.chat
class AliasVoice
  prepend AliasLayer
  alias say speak
  alias_method :tell, :speak
end
p d.talk, d.chat, d.say, d.tell
