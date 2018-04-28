class CallController < ApplicationController
  def index
    @calls = Call.all.order(created_at: :desc)
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
