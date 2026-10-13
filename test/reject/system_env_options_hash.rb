# system's options spread from a Hash value (`**opts`) after an environment
# Hash are not wired to the spawn path, so the call is refused rather than
# converting the options Hash to a String at run time. Options written as
# keyword arguments run (test/system_options.rb).
opts = {exception: true}
p system({"A" => "1"}, "echo [$A]", **opts)
