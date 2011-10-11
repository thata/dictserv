# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec::Matchers.define :have_entry do |word, translation_regex|
  match do |subject|
    j = JSON.parse(subject)
    val = j[word]
    val =~ translation_regex
  end
end

describe "Lookup dictionary" do
  describe "GET /dictionary/lookup?word=hello" do
    it "単語を検索できること" do
      visit "/dictionary/lookup?word=hello"
      page.source.should have_entry("hello", /こんにちは/)
    end
  end

  describe "GET /dictionary/lookup?word=xxxxxx" do
    it "単語を検索できること" do
      visit "/dictionary/lookup?word=xxxxxx"
      page.status_code.should == 404
    end
  end

  describe "GET /dictionary/lookup?word=" do
    it "400 BadRequest が返ること" do
      visit "/dictionary/lookup?word="
      page.status_code.should == 400
    end
  end

  describe "GET /dictionary/lookup?" do
    it "400 BadRequest が返ること" do
      visit "/dictionary/lookup"
      page.status_code.should == 400
    end
  end
end


