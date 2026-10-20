# spinel: int64 -- an exponent of -(2**63 - 1)
# a base of 1 or -1 answers at once whatever the size of the negative
# exponent
p (-1).pow(-9223372036854775807), 1 ** -9223372036854775807, (-1) ** -9223372036854775806
