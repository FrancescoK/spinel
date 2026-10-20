# File::SEPARATOR, PATH_SEPARATOR and NULL are frozen Strings, as CRuby's
# are: they were emitted as bare literals, whose frozen? answered false, and
# a variable that took one beside a new String appended to it.
p File::SEPARATOR.frozen?, File::PATH_SEPARATOR.frozen?, File::NULL.frozen?
z = File::SEPARATOR
p z.frozen?
w = ARGV.empty? ? File::SEPARATOR : +"x"
w << "!" unless w.frozen?
p w, w.frozen?
p File.join("a", "b"), "a#{File::SEPARATOR}b", [1, 2].join(File::PATH_SEPARATOR)
