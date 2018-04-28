Rails.application.routes.draw do
  scope path: 'call' do
    root to: 'call#index'
    delete '/:id', to: 'call#delete'
    get '/:id', to: 'call#show'

    post '/hook', to:'webhook#incoming'

    post '/hook/message', to:'webhook#message'
    post '/hook/status', to: 'webhook#call_status'
  end
end
