require 'spec_helper'
require 'hamster'
require 'hammer/hamster_ext/hash'

describe "hash extensions" do
  describe ".put_in" do
    it "works" do
      expect(Hamster.hash(a: 1).put_in([:a], 2)).to eq(Hamster.hash(a: 2))
      expect(Hamster.hash(a: Hamster.hash(b: 1)).put_in([:a, :b], 2)).to eq(Hamster.hash(a: Hamster.hash(b: 2)))
    end
  end

  describe ".update_in" do
    it "works" do
      expect(Hamster.hash(a: 1).update_in(:a) {|v| v + 1}).to eq(Hamster.hash(a: 2))
      expect(Hamster.hash(a: Hamster.hash(b: 1)).update_in(:a, :b) {|v| v + 1}).to eq(Hamster.hash(a: Hamster.hash(b: 2)))
      expect(Hamster.hash.update_in(:a, :b) {|_| 2}).to eq(Hamster.hash(a: Hamster.hash(b: 2)))
    end
  end

  describe ".get_in" do
    it "works" do
      expect(Hamster.hash(a: 1).get_in(:a)).to eq(1)
      expect(Hamster.hash(a: Hamster.hash(b: 1)).get_in(:a, :b)).to eq(1)
      expect(Hamster.hash.get_in(:a)).to eq(nil)
    end
  end
end
