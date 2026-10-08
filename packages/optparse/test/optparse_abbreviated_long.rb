# A long switch can be shortened to any start that names one switch:
# "--verb" is "--verbose". Each word may be shortened ("--d-r" is
# "--dry-run") and case is ignored. When the start fits several switches,
# the shortest name wins only if it starts all the others ("--lis" is
# "--list" beside "--listen"); otherwise it raises AmbiguousOption. Switches
# given to on are searched before on_tail ones (#7980).
require "optparse"

parser = OptionParser.new("Usage: tool [OPTIONS]")
parser.on("-v", "--verbose") { |v| p [:verbose, v] }
parser.on("--version-check") { |v| p [:version_check, v] }
parser.on("--count=N") { |v| p [:count, v] }
parser.on("--color[=WHEN]") { |v| p [:color, v] }
parser.on("--[no-]dry-run") { |v| p [:dry_run, v] }
parser.on("--list") { |v| p [:list, v] }
parser.on("--listen") { |v| p [:listen, v] }
parser.on("--gray", "--grey") { |v| p [:gray, v] }
parser.on_tail("--verify") { |v| p [:verify, v] }
parser.on_tail("--trace") { |v| p [:trace, v] }

p parser.parse(["--verb", "--vers", "--VERBOSE", "--Ve-C"])
p parser.parse(["--cou=3", "--cou", "4", "--col", "word", "--col=always"])
p parser.parse(["--dry", "--d-r", "--no-d", "--no", "--dry-run"])
p parser.parse(["--lis", "--liste", "--list", "--gr", "--grey"])
p parser.parse(["--tr", "--verif"])

[
  ["--ver"],
  ["--v", "word"],
  ["--c", "3", "b"],
  ["a", "--ver", "b"],
  ["--l-n"],
  ["--cou"],
  ["--verb=x", "b"],
  ["--zzz"]
].each do |words|
  argv = words.dup
  begin
    parser.parse!(argv)
  rescue OptionParser::ParseError => e
    p [e.class, e.message, argv]
  end
end
p OptionParser::AmbiguousOption.superclass
