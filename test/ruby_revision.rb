p RUBY_REVISION.size
p RUBY_REVISION.match?(/\A\h{40}\z/)
p RUBY_REVISION.delete("0-9a-f").empty?
p Object.const_get(:RUBY_REVISION) == RUBY_REVISION
