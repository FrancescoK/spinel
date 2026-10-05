# A String bang method that changed its receiver answers the receiver
# itself. The retained result is a copy today, so an append through it
# would not reach s: refused.
s = +"ab "
r = s.strip!
r << "Z"
p s
