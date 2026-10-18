# An empty Hash a class variable memoizes (`@@h ||= {}`), indexed through
# its reader or through the memo itself, takes its key kind from those
# index writes, as one an ivar holds does: it kept the String-keyed
# default, and a Regexp key raised "no implicit conversion of nil into
# String" (railties' SourceAnnotationExtractor::Annotation registers its
# extensions under Regexp keys at boot).
class Annotation
  def self.extensions
    @@extensions ||= {}
  end

  def self.register_extensions(*exts, &block)
    extensions[/\.(#{exts.join("|")})$/] = block
  end

  register_extensions("builder", "rb", "rake", "ruby") { |tag| "rb:#{tag}" }
  register_extensions("erb") { |tag| "erb:#{tag}" }
end

p Annotation.extensions.keys
p Annotation.extensions.find { |re, _| re.match?("x.erb") }.last.call("TODO")

class Memo
  def self.add(k, v) = ((@@seen ||= {})[k] = v)
  def self.seen = @@seen
end
Memo.add([1, 2], :pair)
Memo.add(:sym, :one)
p Memo.seen

class Plain
  def self.names = (@@names ||= {})
  def self.name_for(k) = (names[k] ||= k.to_s.upcase)
end
p Plain.name_for(:ab), Plain.names
