# A String read out of a boxed slot takes sub, gsub, tr, squeeze and
# delete_prefix as a String, even where a module the program holds as a
# value defines a class method of the same name.
module Params
  def self.sub(params, key) = params[key]
  def self.gsub(params, key) = params[key]
  def self.tr(params, key) = params[key]
  def self.squeeze(key) = key
  def self.delete_prefix(key) = key
end

def transforms(options)
  value = options.fetch(:protocol, "http")
  [value.sub("://", ""), value.gsub("/", "-"), value.tr("s", "S"), value.squeeze("/"), value.delete_prefix("ht")]
end

holder = ARGV.empty? ? Params : "text"
p holder
p Params.sub({ "a" => "b" }, "a")
p transforms({ protocol: "https://", port: 80 })
p transforms({ port: 8080 })
