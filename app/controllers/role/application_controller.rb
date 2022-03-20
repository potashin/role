module Role
  class ApplicationController < ActionController::Base
    rescue_from ActionController::ParameterMissing do |exception|
      render_custom_errors_as_json(exception.full_message)
    end

    rescue_from AbstractController::ActionNotFound do |exception|
      render_custom_errors_as_json(exception.full_message, status: 404)
    end

    include Swagger::Blocks

    def render_as_json(data, meta: {}, status: 200)
      render(json: { meta: meta, data: data }, status: status)
    end

    def render_errors_as_json(item, status: 422)
      render(
        json: {
          errors: item.errors.map { |error|
            {
              field: error.attribute,
              title: error.message,
            }
          }
        },
        status: status
      )
    end

    def render_custom_errors_as_json(*collection, status: 422)
      render(
        json: {
          errors: collection.map { |message| { title: message } }
        },
        status: status
      )
    end

    def type(item)
      item.class.name.underscore.pluralize
    end
  end
end
