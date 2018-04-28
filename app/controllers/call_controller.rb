class CallController < ApplicationController
  def index
    @calls = Call.all
  end

  def show
    @call = Call.find(params['id'])
  end

  def delete
    @call = Call.find(params['id'])
    @call.destroy

    redirect_to '/call'
  end
end
