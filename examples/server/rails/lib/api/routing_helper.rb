module API

  require 'delegate'

  class RoutingHelper < SimpleDelegator
    include ActionController::UrlFor
    include Rails.application.routes.url_helpers


    attr_accessor :request

    def initialize(controller)
      super
      self.request = API::ExtendedRequest.new(controller.request)
    end

  end
end