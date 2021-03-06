Rails.application.routes.draw do
  scope path: 'call' do
    root to: 'call#index'
    get '/:id', to: 'call#show'
    delete '/:id', to: 'call#delete'

    post '/hook', to:'webhook#incoming'

    post '/hook/message', to:'webhook#message'
    post '/hook/status', to: 'webhook#call_status'
  end
end
