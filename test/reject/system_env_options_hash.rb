# system's options Hash is not wired to the spawn path, after an environment
# Hash as without one, so the call is refused rather than converting the
# options Hash to a String at run time.
p system({"A" => "1"}, "echo [$A]", exception: true)
