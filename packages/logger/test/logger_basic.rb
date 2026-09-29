require "logger"
require "stringio"
io = StringIO.new
log = Logger.new(io)
log.level = Logger::INFO
log.debug("hidden")
log.info("hello")
log.warn { "lazy" }
log.error("prog") { "with progname" }
log.add(Logger::FATAL, "boom")
log.log(Logger::WARN, "via log", "dom")
p log.info?, log.debug?
log.formatter = proc { |sev, _t, prog, msg| "#{sev}|#{prog}|#{msg}\n" }
log.progname = "app"
log.info("custom")
log.level = :warn
log.info("dropped")
log.unknown("any")
io.string.each_line { |l| puts l.sub(/\[.*?\]/, "[T]") }
Logger.new(nil).info("nothing")
