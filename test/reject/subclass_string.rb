# A subclass of String: the constructor took none of String's arguments and
# raised ArgumentError at run time (#7075).
# spinel: reject-subclass: class Name < String: subclassing String is not supported yet
class Name < String
end

p Name.new("hi").upcase
