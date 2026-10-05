# chars / bytes / lines / codepoints given their block as a block argument:
# the block-form loop runs a literal block's body, and with `&pr` it ran
# nothing and answered the receiver -- CRuby calls the proc for each element,
# or answers the Array when the argument is nil. Refused; each_char /
# each_byte / each_line take the argument.
pr = proc { |b| p b }
"ab".bytes(&pr)
