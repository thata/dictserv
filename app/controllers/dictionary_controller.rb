class DictionaryController < ApplicationController
  layout nil

  def lookup
    render :json => { "hello" => "hello" }
  end
end
