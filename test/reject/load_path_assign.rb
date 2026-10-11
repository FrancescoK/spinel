# $LOAD_PATH names the one Array the runtime holds; CRuby raises NameError
# for an assignment to it, so a program has to change the Array in place.
$LOAD_PATH = ["/nowhere"]
p $LOAD_PATH
