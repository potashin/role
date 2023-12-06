class ErrorsSerializer < ApplicationSerializer
  def self.call(errors = [])
    new.call(errors)
  end

  def call(errors)
    {errors: errors.map(&method(:build))}
  end

  private

  def build(error)
    ErrorSerializer.call(
      error.attribute,
      error.type,
      message: error.full_message,
      options: error.options,
      root: false
    )
  end
end
