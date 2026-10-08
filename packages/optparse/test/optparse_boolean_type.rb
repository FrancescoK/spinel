require "optparse"

def try(type, argv)
  parser = OptionParser.new
  r = :unset
  parser.on("--c=V", type) { |v| r = v }
  parser.parse(argv)
  r
rescue OptionParser::ParseError => e
  [e.class.name, e.message]
end

%w[y ye yes t tr tru true + n no nil ni f fa fal fals false - YES TRUE maybe yy x].each do |w|
  puts "#{w}: #{try(TrueClass, ["--c=#{w}"]).inspect} #{try(FalseClass, ["--c=#{w}"]).inspect}"
end
p try(TrueClass, ["--c="])
p try(FalseClass, ["--c", ""])
p try(TrueClass, ["--c", "no"])
p try(TrueClass, ["--c=maybe"])

[TrueClass, FalseClass].each do |k|
  parser = OptionParser.new
  parser.on("--f[=YES]", k) { |v| p [k.name, v] }
  parser.on("-d V", k) { |v| p [:d, v] }
  parser.parse(["--f", "--f=n", "-d", "yes", "-dn", "-d-"])
end

parser = OptionParser.new
parser.on("--[no-]flag", TrueClass) { |v| p [:flag, v] }
parser.parse(["--flag", "--no-flag"])
p OptionParser::AmbiguousArgument.superclass
