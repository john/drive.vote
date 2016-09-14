module Api::V1
  class PlacesController < Api::ApplicationController
    include AccessMethods

    before_action :require_internal_access

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
