# DidYouMean::Jaro.distance and DidYouMean::JaroWinkler.distance: how alike
# two Strings are, from 0 to 1.0, Winkler's raised for a common prefix.
# The pairs are the ones ruby/did_you_mean tests.
require "did_you_mean"

[
  %w[henka henkan], %w[al al], %w[martha marhta], %w[jones johnson],
  %w[abcvwxyz zabcvwxy], %w[abcvwxyz cabvwxyz], %w[dwayne duane],
  %w[dixon dicksonx], %w[fvie ten], %w[does_exist doesnt_exist], %w[x x],
  ["變形金剛4:絕跡重生", "變形金剛4: 絕跡重生"], %w[連勝文 連勝丼], %w[馬英九 馬英丸],
  %w[良い いい], ["", ""], ["", "abc"]
].each do |a, b|
  p [DidYouMean::Jaro.distance(a, b).round(4), DidYouMean::JaroWinkler.distance(a, b).round(4)]
end

p DidYouMean::JaroWinkler.distance("abcd", "abce") == DidYouMean::JaroWinkler.distance("abce", "abcd")
