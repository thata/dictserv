require 'spec_helper'

describe DictionaryController do

  describe "GET 'lookup'" do
    it "should be successful" do
      get 'lookup'
      response.should be_success
    end
  end

end
