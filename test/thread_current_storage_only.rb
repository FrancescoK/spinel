Thread.current[:db] ||= "conn"
p Thread.current[:db]
Thread.current[:n] = 3
Thread.current[:n] += 1
p Thread.current[:n]
p Thread.current.key?(:n)
p Thread.current.key?(:zz)
Thread.current.name = "main-x"
p Thread.current.name
