# After `alias $mine $LOAD_PATH` CRuby reads the runtime's Array through the
# new name; here the new name would be an ordinary global, so it is refused.
alias $mine $LOAD_PATH
$LOAD_PATH.unshift "/a"
p $mine.include?("/a")
