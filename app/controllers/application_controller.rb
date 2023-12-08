class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Parameterizable
  include Rescuable

  wrap_parameters(false)
end
