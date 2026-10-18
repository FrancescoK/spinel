# Psych.load_tags and Psych.dump_tags are the module's tag tables, a Hash
# each, empty to begin with, written through as a program registers its
# class's tag (activesupport's time_with_zone.rb, actionpack's Parameters),
# and reached through YAML too.
require 'yaml'

class Stamp; end

p Psych.load_tags, Psych.dump_tags
YAML.load_tags["!ruby/object:Stamp"] = "Stamp"
YAML.dump_tags[Stamp] = "!ruby/object:Stamp"
p Psych.load_tags
p Psych.dump_tags.keys, Psych.dump_tags.values
Psych.load_tags = { "!x" => "Stamp" }
p YAML.load_tags
p YAML.safe_load("a: 1")
