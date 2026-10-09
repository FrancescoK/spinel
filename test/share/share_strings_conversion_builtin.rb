# spinel: share
# spinel: gc-minor
# A boxed conversion without user targets keeps the builtin handle route.
def boxed_text(value) = value
boxed_text(1)
source = +"source"
text = boxed_text(source).to_s
text << "!"
p source, text
p boxed_text(12).to_s
