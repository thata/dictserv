class DictionaryController < ApplicationController
  layout nil

  def lookup
    if params[:word].blank?
      render text: "", status: 400
      return
    end

    dict = Dictionary.new
    result = dict.lookup(params[:word])
    if result
      render :json => dict.lookup(params[:word])
    else
      render text: "", status: 404
    end
  end
end
