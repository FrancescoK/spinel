require_relative "ruby_version_fold_lib/outer"
puts "main continues"
p Object.const_defined?(:Gated)

class Heading
  if RUBY_VERSION >= "3.0" && RUBY_ENGINE != "jruby"
    def kind = "new"
  else
    def kind = "old"
  end
  def legacy = :legacy if RUBY_VERSION < "2"
end
p Heading.new.kind, Heading.new.respond_to?(:legacy)

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7")
  require_relative "ruby_version_fold_lib/old"
end
p Object.const_defined?(:OldRuby)

p RUBY_VERSION < "10", Gem.ruby_version < Gem::Version.new("10"), RUBY_VERSION.start_with?("1.")
