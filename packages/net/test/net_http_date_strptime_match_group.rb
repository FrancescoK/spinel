# A String#match group handed to Date.strptime, in a program that also
# has a Struct with a `match` member and requires net/http, was refused
# inside the date package at parse_day's `str[...] = ...` (#10439). Three
# facts were lost on the way: net/http's `req.method` (a reader, no
# argument) read as a reflection that names any method, so every
# parameter took every class; String#match's MatchData took the classes
# the runtime had seen; and the desugared `[]=`'s receiver, a read made
# after the class facts, had none, so the Struct's `[]=` stayed an arm.
module Capture
  class Catalog
    TrackSpec = Struct.new(
      :position, :track_id, :uri, :title, :artists, :album, :album_artist,
      :album_id, :album_artists, :release_date_precision, :release_type,
    ) do
    end
    def spec_for(t, album, position:, disc_total:)
      album_artists = artist_names(album["artists"])
      TrackSpec.new(
        album_artists: album_artists,
      )
    end
    def artist_names(artists) = (artists || []).map { |a| a["name"] }
  end
  module Soloist
    module_function
    def parse_version(text)
      m = text.match(/^soloist\s+(\S+)\s+build\s+\d+\s+\((\d{8})\)\s+\(\S+\)\s+\(([^)]+)\)/)
      Date.strptime(m[2], "%Y%m%d").to_s
    end
  end
end
module Capture
  Source = Struct.new(:match) do
  end
end
require "date"
require "net/http"
module Capture
  class Preflight
    def soloist_build
      text = @version_text == :read ? read_version : @version_text
      version = Soloist.parse_version(text)
    end
    def read_version
    end
  end
end
p Capture::Soloist.parse_version("soloist 1.3 build 17 (20260911) (g5c) (linux/x86_64)")
p Capture::Catalog.new.spec_for({}, { "artists" => [{ "name" => "x" }] }, position: 1, disc_total: 1).album_artists
p Capture::Source.new("m").match
p Capture::Preflight.new.read_version
