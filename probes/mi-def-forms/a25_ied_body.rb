class K
  instance_eval do
    def m = :km
  end
  p m
end
p K.m
