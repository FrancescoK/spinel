# A cached reference follows edits, additions, removals and required data
# in the current corpus, while an unchanged corpus reuses the build.
puts `bash tools/cident_cache_test.sh corpus`
