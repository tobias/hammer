require 'hammer/reader'

module Hammer
  class << self
    def read(str)
      Hammer::Reader.new.read(str)
    rescue Parslet::ParseFailed => e
      puts e.cause.ascii_tree
    end

    def eval(str)
      read(str).eval
    end
  end
end
