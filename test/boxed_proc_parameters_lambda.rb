# parameters(lambda: true/false/nil) on a Proc read out of a container
# answers the view the keyword asks for, as on a typed Proc.
pr = [proc { |a, b = 1| }, 0][0]
p pr.parameters
p pr.parameters(lambda: true)
p pr.parameters(lambda: false)
p pr.parameters(lambda: nil)
l = [lambda { |x, y| }, 0][0]
p l.parameters(lambda: false)
p l.parameters(lambda: true)
p l.parameters(lambda: nil)
p ([nil, 0][0].parameters(lambda: true) rescue $!.message)
