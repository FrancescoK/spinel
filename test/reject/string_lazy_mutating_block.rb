# A lazy map block appending to its element changes s itself. It crashed:
# refused rather than compiled.
s = +"abc"
[s].lazy.map { |x| x << "!" }.first
p s
