module Rescuable
  extend ActiveSupport::Concern

  included do
    rescue_from(ActionController::ParameterMissing, with: :handle_parameter_missing)
    rescue_from(AbstractController::ActionNotFound, with: :handle_action_not_found)
    rescue_from(ActiveRecord::RecordNotFound, with: :handle_record_not_found)
    rescue_from(ApplicationForm::Error, with: :handle_form_error)
    rescue_from(Exceptions::InvalidParameter, with: :handle_invalid_parameter)
  end

  private

  def handle_parameter_missing(exception)
    json = ErrorSerializer.call(:parameter, :missing, message: exception.full_message)

    render(json:, status: :unprocessable_entity)
  end

  def handle_action_not_found(exception)
    json = ErrorSerializer.call(:action, :not_found, message: exception.full_message)

    render(json:, status: :not_found)
  end

  def handle_record_not_found(exception)
    json = ErrorSerializer.call(:record, :not_found, message: exception.full_message)

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
      message: exception.full_message,
      options: exception.options
    )

    render(json:, status: :bad_request)
  end
end
