# Library code asks RubyGems and RbConfig platform questions without a
# require; both answer.
p Gem.win_platform?
p RbConfig::CONFIG["host_os"].is_a?(String)
p RbConfig::CONFIG["host_os"] =~ /darwin|linux/ ? true : false
