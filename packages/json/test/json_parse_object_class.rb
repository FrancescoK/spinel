# JSON.parse(object_class: OpenStruct) builds an OpenStruct for every parsed
# object, nested ones and those inside arrays too, as CRuby's parser does;
# its members read as methods and as [] with a Symbol.
require "json"
require "ostruct"

text = '{"site":{"locales":["en","pl"],"currency":"EUR"},"routes":[{"path":"/a"},{"path":"/b"}],"n":3}'
cfg = JSON.parse(text, object_class: OpenStruct)
puts cfg.class
p cfg.site.locales
p cfg.site.currency
p cfg.n
p cfg.missing
p cfg[:site][:currency]
p JSON.parse('[{"a":1},2]', object_class: OpenStruct).first.a
p JSON.parse('{"outer":{"inner":1}}', object_class: OpenStruct, symbolize_names: true).outer.inner
p JSON.parse('{"a":1}', object_class: Hash)
