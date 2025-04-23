class Api::StoresController < ApplicationController
  def index
    stores = Store.all.limit(10)

    render json: {
      stores: stores
    }, status: :ok
  end
end
