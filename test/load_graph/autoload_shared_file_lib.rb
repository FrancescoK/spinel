puts "shared lib loaded"
p [:inside, defined?(SharedA), defined?(SharedB)]
SharedA = 1
SharedB = 2
p [:assigned, defined?(SharedA), defined?(SharedB)]
