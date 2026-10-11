# $LOAD_PATH, $: and $-I name one Array of Strings the program can read and
# change. minitest's tests save a copy in setup and put it back in teardown.
saved = $LOAD_PATH.dup
p saved.class
p $:.equal?($LOAD_PATH)
p $-I.equal?($:)

$LOAD_PATH.unshift "/nowhere/lib"
$: << "/nowhere/test"
p $LOAD_PATH - saved
p $:.first
p $LOAD_PATH.include?("/nowhere/test")

class Restore
  def setup = @orig = $LOAD_PATH.dup
  def teardown = $LOAD_PATH.replace(@orig)
end
r = Restore.new
r.setup
$LOAD_PATH.push "/nowhere/more"
p ($LOAD_PATH - saved).size
r.teardown
p ($LOAD_PATH - saved).size

$LOAD_PATH.replace saved
p $LOAD_PATH == saved
p $LOAD_PATH.grep(/nowhere/)

p defined?($LOAD_PATH)
p defined?($:)
p defined?($-I)
