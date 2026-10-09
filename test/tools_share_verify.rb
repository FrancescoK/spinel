# The sharing verifier rejects new conflicts, compile failures and changed C,
# and reminds about stale entries, including when an input path contains spaces.
puts `ruby tools/share_verify_test.rb`
