# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Dictionary" do
  describe "lookup" do
    it "hello" do
      dic = Dictionary.new
      r = dic.lookup("hello")
      r["hello"].should =~ /こんにちは/
    end
  end
end
