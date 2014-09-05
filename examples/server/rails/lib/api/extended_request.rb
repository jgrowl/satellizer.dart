module API

  require 'delegate'

  class ExtendedRequest < SimpleDelegator

    def symbolized_path_parameters
      ActiveSupport::Deprecation.warn(
          "`symbolized_path_parameters` is deprecated. Please use `path_parameters`"
      )
      path_parameters
    end

    # Returns a hash with the \parameters used to form the \path of the request.
    # Returned hash keys are strings:
    #
    # {'action' => 'my_action', 'controller' => 'my_controller'}
    def path_parameters
      {}
    end

    # Returns 'https://' if this is an SSL request and 'http://' otherwise.
    def protocol
      @protocol ||= ssl? ? 'https://' : 'http://'
    end

    # Returns the standard \port number for this request's protocol.
    def standard_port
      if ssl?
        443
      else
        80
      end
    end

    # Returns whether this request is using the standard port
    def standard_port?
      port == standard_port
    end

    # Returns a number \port suffix like 8080 if the \port number of this request
    # is not the default HTTP \port 80 or HTTPS \port 443.
    def optional_port
      standard_port? ? nil : port
    end
  end

end