require 'spec_helper'

describe Hammer::Reader do
  let(:reader) {Hammer::Reader.new}

  describe '.parse' do
    ["0", "false", "true", '"foo"', ":foo", "foo", "'foo",
     "(a b c)",
     "'(a b c)",
     '(a "b" :c)',
     '()',
     "'()",
     "[a b c]",
     "[]",
     "[:foo]",
     "(a [] foo)"
    ].each do |form|
      it "parses |#{form}|" do
        expect(reader).to parse(form)
      end
    end
  end
end
