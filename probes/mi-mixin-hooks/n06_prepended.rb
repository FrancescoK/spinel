# prepended: hook fires on prepend, not when defined later
module M
  def self.prepended(b) = puts("pre #{b}")
end
class A
  prepend M
end
module N; end
class B; prepend N; end
module N
  def self.prepended(b) = puts("pre N #{b}")
end
class C; prepend N; end
