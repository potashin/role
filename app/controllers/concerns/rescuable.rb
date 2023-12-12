module Rescuable
  extend ActiveSupport::Concern

  included do
    rescue_from(ActionController::ParameterMissing, with: :handle_parameter_missing)
    rescue_from(AbstractController::ActionNotFound, with: :handle_not_found)
    rescue_from(ActiveRecord::RecordNotFound, with: :handle_not_found)
    rescue_from(ApplicationForm::Error, with: :handle_form_error)
    rescue_from(Exceptions::InvalidParameter, with: :handle_invalid_parameter)
  end

  def handle_parameter_missing(exception)
    json = ErrorSerializer.call(:parameter, :missing, message: exception.message)

    render(json:, status: :unprocessable_entity)
  end

  def handle_not_found(exception)
    json = ErrorSerializer.call(nil, :not_found, message: exception.message)

    render(json:, status: :not_found)
  end

  def handle_form_error(exception)
    json = ErrorsSerializer.call(exception.form.errors)

    render(json:, status: :unprocessable_entity)
  end

  def handle_invalid_parameter(exception)
    json = ErrorSerializer.call(
      exception.attribute,
      exception.type,
      message: exception.message,
      options: exception.options
    )

    render(json:, status: :bad_request)
  end
end
