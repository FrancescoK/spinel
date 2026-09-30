p defined?(RUBY_VERSION)
p defined?(RUBY_ENGINE)
p defined?(RUBY_ENGINE_VERSION)
p defined?(RUBY_PLATFORM)
p defined?(RUBY_RELEASE_DATE)
p defined?(RUBY_REVISION)
p defined?(RUBY_COPYRIGHT)
p defined?(RUBY_DESCRIPTION)
p defined?(::RUBY_VERSION)
p defined?(Object::RUBY_ENGINE)
v = RUBY_VERSION if defined?(RUBY_VERSION)
p v.class
p (defined?(RUBY_ENGINE) && RUBY_ENGINE).class
