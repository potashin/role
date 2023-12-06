# frozen_string_literal: true

# config/initializers/locale.rb

# Where the I18n library should search for translation files
# I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]

# Whitelist locales available for the application
I18n.available_locales = %i[en]

# Set default locale to something other than :en
I18n.default_locale = :en

if Rails.env.test? || Rails.env.development?
  module I18n
    class CustomExceptionHandler < ExceptionHandler
      def call(exception, _locale, key, _options)
        raise_missing_translation_error?(exception, key) ? raise(exception.to_exception) : super
      end

      def raise_missing_translation_error?(exception, key)
        exception.is_a?(I18n::MissingTranslation) && not_plural_rule?(key)
      end

      def not_plural_rule?(key)
        key.to_s != 'i18n.plural.rule'
      end
    end
  end

  I18n.exception_handler = I18n::CustomExceptionHandler.new
end
