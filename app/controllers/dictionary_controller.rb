class DictionaryController < ApplicationController
  layout nil

  def lookup
    dict = Dictionary.new
    render :json => dict.lookup(params[:word])
  end
end
