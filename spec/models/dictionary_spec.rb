# -*- encoding: utf-8 -*-

describe "Dictionary" do
  describe "lookup" do
    it "hello" do
      pending "app/modelsがロードパスに入らないなあ..."
      $:.each {|p| puts p }

      dic = Dictionary.new
      r = dic.lookup("hello")
      r["hello"].should =~ /こんにちは/
    end
  end
end
