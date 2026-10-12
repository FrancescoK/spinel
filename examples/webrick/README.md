# WEBrick Hello World

This example showcases Spinel with a WEBrick server and a Minitest runner.
Spinel compiles both into separate native executables from unmodified gem sources.

## Build and run the server

Use a C compiler, Make, and Ruby with RubyGems. This example was checked with
CRuby 4.0.5, WEBrick 1.9.2, and Minitest 6.0.6.

From the Spinel repository root:

```sh
cd examples/webrick

# 1. Install the pinned WEBrick and Minitest gems, reusing existing installations.
# 2. Fetch Spinel's parser dependencies and build the compiler.
# 3. Create the output directory.
make

WEBRICK_LIB=$(ruby -rrubygems -e 'print Gem::Specification.find_by_name("webrick", "= 1.9.2").full_gem_path + "/lib"')
BUILD_DIR=../../build/examples/webrick

../../bin/spinel --defer-refusals -I "$WEBRICK_LIB" \
  server.rb -o "$BUILD_DIR/server" > "$BUILD_DIR/server.log" 2>&1

PORT=8080 "$BUILD_DIR/server"
```

The server defaults to port 9292. Set `PORT` to an available port, as above.
In another terminal:

```sh
curl http://127.0.0.1:8080/
# Hello, world!
```

Use the same port in the server command and the request URL. Press Ctrl-C to stop the server.

## Build and run the tests

In another terminal, from the Spinel repository root:

```sh
cd examples/webrick
MINITEST_LIB=$(ruby -rrubygems -e 'print Gem::Specification.find_by_name("minitest", "= 6.0.6").full_gem_path + "/lib"')
BUILD_DIR=../../build/examples/webrick

../../bin/spinel --defer-refusals -I "$MINITEST_LIB" \
  test_hello_world.rb -o "$BUILD_DIR/test_hello_world" > "$BUILD_DIR/test_hello_world.log" 2>&1

MT_CPU=1 HELLO_WORLD_SERVER="$BUILD_DIR/server" \
  "$BUILD_DIR/test_hello_world" --seed 1
```

The test starts its own native server on an OS-assigned port and stops it afterward.
It checks the HTTP status, content type, response body, and clean server shutdown.
A successful run reports four assertions and no failures or errors.

To run the same test with CRuby, from `examples/webrick`:

```sh
WEBRICK_LIB=$(ruby -rrubygems -e 'print Gem::Specification.find_by_name("webrick", "= 1.9.2").full_gem_path + "/lib"')
MINITEST_LIB=$(ruby -rrubygems -e 'print Gem::Specification.find_by_name("minitest", "= 6.0.6").full_gem_path + "/lib"')
MT_CPU=1 SERVER_RUBY="$(command -v ruby)" \
  HELLO_WORLD_SERVER="$PWD/server.rb" \
  ruby -I "$WEBRICK_LIB" -I "$MINITEST_LIB" test_hello_world.rb --seed 1
```

## Current requirements

The builds use `--defer-refusals` because the gems include optional paths that
Spinel does not support. If execution reaches those paths, they still raise an error.
The test uses `MT_CPU=1` to avoid unsupported parallel-test paths.

The native executables and compiler logs are in the repository's `build/examples/webrick/` directory.
