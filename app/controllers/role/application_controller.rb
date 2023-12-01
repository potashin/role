module Role
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds

    rescue_from ActionController::ParameterMissing do |exception|
      json = ErrorSerializer.call(:parameter, :missing, message: exception.full_message)
      render(json:, status: 422)
    end

    rescue_from AbstractController::ActionNotFound do |exception|
      json = ErrorSerializer.call(:action, :not_found, message: exception.full_message)
      render(json:, status: 404)
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      json = ErrorSerializer.call(:record, :not_found, message: exception.full_message)
      render(json:, status: 404)
    end

    rescue_from Role::ApplicationForm::Error do |exception|
      json = Role::ErrorsSerializer.call(exception.form.errors)
      render(json:, status: 422)
    end
  end
end
