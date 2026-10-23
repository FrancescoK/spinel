# IO#gets sets $_ in CRuby (this prints "a\n" twice); here it does not, so
# $_ would read nil. The gets is refused, not answered wrongly.
s = $stdin.gets
p s, $_
