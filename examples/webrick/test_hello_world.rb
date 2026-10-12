require "minitest/autorun"
require "net/http"

class HelloWorldTest < Minitest::Test
  def setup
    server_path = ENV.fetch("HELLO_WORLD_SERVER")
    command = [server_path]
    command.unshift(ENV["SERVER_RUBY"]) if ENV["SERVER_RUBY"]

    @output, writer = IO.pipe
    begin
      @pid = Process.spawn({ "PORT" => "0" }, *command, out: writer)
    ensure
      writer.close
    end

    raise "WEBrick did not start within 5 seconds" unless IO.select([@output], nil, nil, 5)
    listening = @output.gets.to_s
    raise "WEBrick exited before listening" unless listening.start_with?("Listening on ")
    @port = URI(listening.delete_prefix("Listening on ").strip).port
  end

  def teardown
    if @pid
      Process.kill("TERM", @pid)
      _, status = Process.waitpid2(@pid)
      assert status.success?, "WEBrick did not shut down cleanly"
    end
  ensure
    @output&.close
  end

  def test_hello_world_over_http
    client = Net::HTTP.new("127.0.0.1", @port, nil)
    client.open_timeout = 5
    client.read_timeout = 5
    response = client.get("/")

    assert_equal "200", response.code
    assert_equal "text/plain; charset=utf-8", response["content-type"]
    assert_equal "Hello, world!\n", response.body
  end
end
