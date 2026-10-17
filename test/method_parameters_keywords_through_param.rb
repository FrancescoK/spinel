# A Method that reaches #parameters through a parameter reads them from the
# description its value carries. Keywords keep their kinds there, as they do
# when the method is named directly: optparse's define_by_keywords reads them
# this way.
def run(name:, count: 1); end

def kinds(m) = m.parameters

p method(:run).parameters
p kinds(method(:run))
