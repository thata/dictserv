# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Lookup dictionary" do
  describe "GET /dictionary/lookup" do
    it "単語を検索できること" do
      visit "/dictionary/lookup?word=hello"
      j = JSON.parse page.source
      j.should == { "hello" => "こんにちは" }
    end
  end
end
