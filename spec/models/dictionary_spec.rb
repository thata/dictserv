# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Dictionary" do
  describe "lookup" do
    it "helloの検索結果に「こんにちは」が含まれること" do
      dic = Dictionary.new
      r = dic.lookup("hello")
      r["hello"].should =~ /こんにちは/
    end

    it "fishの検索結果が「魚」ではじまること" do
      dic = Dictionary.new
      r = dic.lookup("fish")
      r.keys.size.should == 21
      r["fish"].should =~ /魚肉/
      r["fisher"].should =~ /漁夫/
    end
  end
end
