# frozen_string_literal: true
# spinel: defer-refusals

# A vendored library's file whose unsupported statements raise where they
# run: the pragma turns its refusals into NotImplementedError at run time,
# as --defer-refusals does for every file, so a program that never calls
# them builds (sqlite3's database.rb, whose create_aggregate builds a class
# per call).
module Aggregates
  class Registry
    def initialize
      @functions = {}
    end

    def define(name, &block)
      @functions[name] = block
    end

    def call(name, *args)
      @functions.fetch(name).call(*args)
    end

    def create_aggregate(name, step = nil, finalize = nil, &block)
      proxy = Class.new do
        def self.step(&block)
          define_method(:step_with_ctx, &block)
        end

        def self.finalize(&block)
          define_method(:finalize_with_ctx, &block)
        end
      end
      proxy.instance_eval(&block) if block
      @functions[name] = proxy
    end

    def names
      @functions.keys.sort
    end
  end
end
