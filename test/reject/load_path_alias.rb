# After `alias $LOAD_PATH $mine` CRuby reads the program's own global
# through the name; here the name is the runtime's Array, so it is refused.
$mine = ["/m"]
alias $LOAD_PATH $mine
p $LOAD_PATH
