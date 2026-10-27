# What a require of a native library or a core capability answers, as a
# value: true the first time for the libraries CRuby loads on demand, false
# for the ones it has loaded at boot and for a core capability.
p require("time")
p require("time")
p require("monitor")
p require("socket")
p require("ostruct")
p require("io/console")
p require("set")
p require("thread")
p [require("socket"), require("ostruct"), require("io/console")]
def again = require("time")
p again
