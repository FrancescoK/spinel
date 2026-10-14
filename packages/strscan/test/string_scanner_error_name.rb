# StringScanner::Error names itself as CRuby does, through #class, #inspect,
# a message's full form and a rescue by its path or by StandardError.
require 'strscan'

s = StringScanner.new('a')
begin
  s.unscan
rescue StringScanner::Error => e
  p e.class
  p e
  puts e.class.name
  p e.is_a?(StandardError)
end

begin
  s.unscan
rescue StandardError => e
  puts "#{e.class}: #{e.message}"
end

p StringScanner::Error
