p Object::RUBY_VERSION == RUBY_VERSION
p ::RUBY_VERSION == RUBY_VERSION
p ::Object::RUBY_ENGINE == RUBY_ENGINE
p Object::RUBY_ENGINE_VERSION.class
p Object::RUBY_PLATFORM == RUBY_PLATFORM
p Object::RUBY_RELEASE_DATE.size
p Object::RUBY_REVISION.class
p Object::RUBY_COPYRIGHT.start_with?("ruby - Copyright")
p Object::RUBY_DESCRIPTION.class
p Object::STDOUT == STDOUT
p Object.const_get(:RUBY_VERSION) == RUBY_VERSION
p Object.const_get("RUBY_ENGINE") == RUBY_ENGINE
p Object.const_get(:RUBY_PLATFORM).size > 0
p Object.const_get(:String)
p Object.const_defined?(:RUBY_VERSION)
p Object.const_defined?(:RUBY_ENGINE)
p Object.const_defined?(:RUBY_ENGINE_VERSION)
p Object.const_defined?(:RUBY_PLATFORM)
p Object.const_defined?(:RUBY_RELEASE_DATE)
p Object.const_defined?(:RUBY_REVISION)
p Object.const_defined?(:RUBY_COPYRIGHT)
p Object.const_defined?(:RUBY_DESCRIPTION)
p Object.const_defined?(:STDOUT)

class Probe
  def self.parts = Object::RUBY_VERSION.split(".").size
  def engine = Object.const_get(:RUBY_ENGINE).class
end
p Probe.parts
p Probe.new.engine
