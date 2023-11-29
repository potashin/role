module Role
  class ApplicationController < ActionController::Base
    rescue_from ActionController::ParameterMissing do |exception|
      render_custom_errors_as_json(exception.full_message)
    end

    rescue_from AbstractController::ActionNotFound do
      render_custom_errors_as_json(exception.full_message)
    end

    rescue_from ActiveRecord::RecordNotFound do
      head(404)
    end

    rescue_from Role::ApplicationForm::Error do |exception|
      json = Role::ErrorsSerializer.call(exception.form.errors)
      render(json:, status: 422)
    end

    def render_custom_errors_as_json(*collection, status: 422)
      render(
        json: {
          errors: collection.map { |message| {title: message} }
        },
        status:
      )
    end
  end
end
