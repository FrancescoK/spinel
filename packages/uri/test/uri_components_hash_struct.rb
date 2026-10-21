# URI's components_hash builds an Array's components in a Hash of its own.
# Stored into the variable that also holds the caller's keywords, the store
# took a receiver that may be any of the program's Structs, and a program
# with a String-holding Struct beside net/http was refused at compile time
# in uri.rb (#9258).
require "net/http"
Result = Struct.new(:track, :path, :state, :duration, :expected_duration, :problems, :verification, :metrics, keyword_init: true)
Metrics = Struct.new(:polls, keyword_init: true)
metrics = Metrics.new(polls: 0)
p Result.new(track: 1, path: "a.flac", state: :finished, problems: [], verification: nil, metrics: metrics)
p URI::HTTP.build(["u:p", "example.com", 8080, "/a", "q=1", "f"]).to_s
p URI::HTTPS.build(host: "example.com", path: "/s").to_s
