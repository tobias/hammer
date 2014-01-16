require 'spec_helper'

describe Hammer do
  describe '.eval' do
    it "evals simple expressions" do
      expect(Hammer.eval("0")).to eq(0)
      expect(Hammer.eval("true")).to eq(true)
      expect(Hammer.eval("false")).to eq(false)
      expect(Hammer.eval('"foo"')).to eq("foo")
      expect(Hammer.eval(':foo')).to eq(:foo)
    end

     it "evals collections" do
       expect(Hammer.eval("'(foo)")).to eq(Hamster.list(Hammer::Symbol.new(Hamster.hash(line: 1, col: 3), "foo")))
       expect(Hammer.eval("[:foo]")).to eq(Hamster.vector(:foo))
     end
    
    it "evals quoted symbols as themselves" do
      expect(Hammer.eval("'foo")).to eq(Hammer::Symbol.new(Hamster.hash({line: 1, col: 2}), "foo"))
    end

    it "evals the if special form" do
      expect(Hammer.eval("(if true :foo :bar)")).to eq(:foo)
      expect(Hammer.eval("(if false :foo :bar)")).to eq(:bar)
      expect(Hammer.eval("(if true :foo)")).to eq(:foo)
      expect(Hammer.eval("(if false :foo)")).to eq(nil)
    end

    it "evals the fn special form" do
      expect(Hammer.eval("((fn [a] a) :foo)")).to eq(:foo)
      expect(Hammer.eval("((fn [a] a :bar) :foo)")).to eq(:bar)
    end

    it "evals the let special form" do
      expect(Hammer.eval("(let [a :foo] :foo)")).to eq(:foo)
    end

    # it "captures the environment in fn" do
    #   expect(Hammer.eval("(let [a :foo] ((fn [] a)))")).to eq(:foo)
    # end

    it "evals interop form" do
      expect(Hammer.eval('(.upcase "foo")')).to eq("FOO")
    end
    
  end
end
