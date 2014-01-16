require 'parslet'
require 'hamster'
require 'hammer/forms'

module Hammer
  class ReaderTransform < Parslet::Transform
    
    rule(integer: simple(:x))  { |d| Value.new(position_meta(d[:x]), d[:x].to_i) }
    rule(boolean: simple(:x))  { |d| Value.new(position_meta(d[:x]), d[:x].to_str == "true") }
    rule(symbol: simple(:x))   { |d| Symbol.new(position_meta(d[:x]), d[:x].to_str) }
    rule(string: simple(:x))   { |d| Value.new(position_meta(d[:x]), d[:x].to_str) }
    rule(interop: simple(:x))  { |d| IopCall.new(position_meta(d[:x]), d[:x].to_str) }
    rule(keyword: simple(:x))  { |d| Value.new(position_meta(d[:x]), d[:x].to_sym) }
    rule(list: simple(:x))     { List.new(Hamster.list(x)) }
    rule(list: sequence(:x))   { List.new(Hamster.list(*x)) }
    rule(vector: sequence(:x)) { Value.new({}, Hamster.vector(*x)) }
    rule(quoted: simple(:x))   { Quoted.new(x) }
    rule(body: sequence(:x))   { Body.new(x) }
    
    def self.position_meta(slice)
      Hamster.hash([:line, :col].zip(slice.line_and_column))
    end
    
  end

  class Reader < Parslet::Parser
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:newline) {str("\n")}
    rule(:symchars) { boolean.absent? >> match['a-zA-Z_*=/+!-'] >> match['a-zA-Z0-9_*=/+!-'].repeat }
    rule(:digit) { match['0-9'] }

    rule(:comment) { str(';') >> (newline.absent? >> any).repeat }
    rule(:quoted) { ((str("'") >> expression) | (str('(quote ') >> expression >> str(')'))).as(:quoted) }
    
    rule(:integer) { (str('-').maybe >> digit).repeat(1).as(:integer) >> space? }
    rule(:boolean) { (str('true') | str('false')).as(:boolean) >> space? }
    rule(:symbol) { symchars.as(:symbol) >> space? }
    rule(:interop) { (str('.') >> symchars).as(:interop) >> space? }
    rule(:keyword) { str(':') >> symchars.as(:keyword) >> space? }
    rule(:string) { str('"') >> (str('\\') >> any |
                                 str('"').absent? >> any).repeat.as(:string) >> str('"') >> space? }

    rule(:vector) { str("[") >> space? >> expression.repeat.as(:vector) >> str(']') >> space? }
    rule(:list) { str("(") >> space? >> ((expression | interop).maybe >> expression.repeat).as(:list) >> str(')') >> space? }

    rule(:expression) { symbol | keyword | list | vector | string | integer | quoted | comment | boolean }
    rule(:body) { (space? >> expression).repeat.as(:body) }
    
    root :body

    def reader_transform_chain
      @reader_transform_chain ||= [ReaderTransform].map(&:new)
    end

    def read(str)
      reader_transform_chain.inject(parse(str)) do |data, transform|
        transform.apply(data)
      end
    end
  end
end
