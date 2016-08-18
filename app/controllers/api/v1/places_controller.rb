module Api::V1
  class PlacesController < Api::ApplicationController

    def search
      results = GooglePlaces.search(params[:query])
      if results
        render json: {response: results}
      else
        render json: {error: 'Google Places query failed'}
      end
    end
  end
end
