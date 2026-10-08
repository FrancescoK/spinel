# A fresh String receiver cannot share its append through tap.
# spinel: reject-share
p((+"a").tap { |x| x << "!" })
