# `require "psych"` defines Psych and not YAML, as in CRuby (YAML is
# yaml.rb's alias).
require "psych"

p defined?(YAML)
p Psych.safe_load("k: v")
