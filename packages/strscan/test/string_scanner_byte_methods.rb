# StringScanner#peek_byte, #scan_byte and #get_byte (strscan 3.1): the byte
# at the scan pointer as an Integer, left in place or taken, and taken as a
# one-byte String, each nil at the end. Action Dispatch's journey scanner
# reads the byte ahead with peek_byte.
require "strscan"

s = StringScanner.new("ab\xE3\x81\x82")
p s.peek_byte, s.pos, s.matched
p s.scan_byte, s.pos, s.matched
p s.get_byte, s.pos, s.matched
p s.peek_byte, s.scan_byte, s.pos
s.terminate
p s.peek_byte, s.scan_byte, s.get_byte
