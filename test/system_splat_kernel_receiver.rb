# system with a splat spreads the command and its arguments at run time, as
# the literal list does (it was C that did not compile, #7868), and Kernel's
# module functions exec and spawn are callable with Kernel as the receiver, as
# system and puts are (it raised "private method" at run time, #7869).
args = ["echo", "a"]
p system(*args)
args = ["a", "b"]
p system("echo", *args)
def run(*args) = system(*args)
p run("echo", "b")
def run2(*args) = system("echo", *args)
p run2("d", "e")
system(*["echo", "stmt"])
p system(*["false"])
pid = Kernel.spawn("echo", "g")
Process.wait(pid)
Kernel.exec("echo", "kernel-exec")
