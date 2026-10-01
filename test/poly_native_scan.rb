# A local holding a StringScanner in one branch and an Integer in another
# reaches StringScanner#scan through the dispatch on its runtime class: the
# String-only `scan` shortcut is for programs where no class of the
# program's own answers it (the pure-Ruby Date's zone parser reuses `sc`).
require "strscan"

def offset_of(zone)
  if zone.start_with?("+", "-")
    sc = StringScanner.new(zone)
    if sc.scan(/([+-])(\d{2}):?(\d{2})\z/)
      sign = sc[1] == "-" ? -1 : 1
      return sign * (sc[2].to_i * 3600 + sc[3].to_i * 60)
    end
    return nil
  end
  sc = zone.to_i
  sc * 60
end

p offset_of("+09:00"), offset_of("-0530"), offset_of("+bad"), offset_of("7")
p "a1b22".scan(/\d+/)
