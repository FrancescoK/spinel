# $0 and $PROGRAM_NAME are one assignable value, as in CRuby (Thor's
# basename reads it; a test sets it).
$PROGRAM_NAME = "hm"
p $PROGRAM_NAME
p $0
$0 = "other"
p $PROGRAM_NAME
p File.basename($PROGRAM_NAME)
