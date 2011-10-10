# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Lookup dictionary" do
  describe "GET /dictionary/lookup" do
    it "単語を検索できること" do
      pending "辞書を実装してから"
      visit "/dictionary/lookup?word=hello"
      j = JSON.parse page.source
      j.should == { "hello" => "こんにちは" }
    end
  end
end
