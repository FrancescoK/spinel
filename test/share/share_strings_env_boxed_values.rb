# spinel: gc-minor
# ENV copies the live bytes of a String, including a shared String inside
# a polymorphic box. Hash updates accept those boxes and nil deletions too.
class EnvString
  def value = +"ab"
end
class EnvNumber
  def value = 7
end
objects = [EnvString.new, EnvNumber.new]
ENV["SPINEL_BOXED_ENV"] = objects[0].value
p ENV["SPINEL_BOXED_ENV"]
value = objects[0].value
ENV.store("SPINEL_BOXED_ENV", value)
other = value
other << "!"
p ENV["SPINEL_BOXED_ENV"], value
value = [+"cd", 1][0]
other = value
other << "?"
ENV["SPINEL_BOXED_ENV"] = value
p ENV["SPINEL_BOXED_ENV"], value
pairs = {"SPINEL_BOXED_ENV" => value, "SPINEL_BOXED_ENV_DELETE" => nil}
ENV["SPINEL_BOXED_ENV_DELETE"] = "old"
ENV.update(pairs)
p ENV["SPINEL_BOXED_ENV"], ENV["SPINEL_BOXED_ENV_DELETE"]
ENV.merge!(pairs)
p ENV["SPINEL_BOXED_ENV"]
ENV.replace(pairs)
p ENV["SPINEL_BOXED_ENV"], ENV["SPINEL_BOXED_ENV_DELETE"]
ENV["SPINEL_BOXED_ENV"] = nil
p ENV["SPINEL_BOXED_ENV"]
begin
  ENV["SPINEL_BOXED_ENV"] = objects[1].value
rescue TypeError => error
  puts error.message
end
