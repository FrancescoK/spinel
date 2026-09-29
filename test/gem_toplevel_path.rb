# A leading `::Gem` names the top-level Gem (library code writes it to skip
# a local constant of the name), and RbConfig's ruby_version is the API
# version, the patch level zeroed.
p ::Gem.win_platform?
p RbConfig::CONFIG["ruby_version"].end_with?(".0")
p RbConfig::CONFIG["ruby_version"].split(".")[0, 2] == RUBY_VERSION.split(".")[0, 2]
