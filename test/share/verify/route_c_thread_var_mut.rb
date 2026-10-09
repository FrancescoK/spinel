s = +"abc"
t = s
Thread.current.thread_variable_set(:k, s); Thread.current.thread_variable_get(:k) << "!"
p s
p t
