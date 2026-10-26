# `defined?(X) && X` reads a constant the program may not have. When the
# program defines it nowhere, the guard is false and the right arm never
# runs, so the build says nothing about it, as for `defined?(X) ? X : nil`.
# A reference outside such a guard still gets the defined-nowhere warning.
def version = @version || (defined?(::Version) && ::Version) || "none"
def release = defined?(Release) && Release
def tag = defined?(::Tag) && ::Tag.upcase
def gone = (defined?(::Gone) and ::Gone)
def chain = defined?(::Version) && defined?(::Other) && ::Other
def here = defined?(::Here) && ::Here

Here = "here"

p version
p release
p tag
p gone
p chain
p here
