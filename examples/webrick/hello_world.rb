require "webrick"

module HelloWorld
  def self.build(port: 9292)
    server = WEBrick::HTTPServer.new(
      BindAddress: "127.0.0.1",
      Port: port,
      Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN),
      AccessLog: [],
    )

    server.mount_proc("/") do |_request, response|
      response.status = 200
      response["Content-Type"] = "text/plain; charset=utf-8"
      response.body = "Hello, world!\n"
    end

    server
  end
end
