# A fresh Array cannot lend its String element to an appending block.
# spinel: reject-share
p([+"a"].each { |x| x << "!" })
