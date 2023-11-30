module Role
  module Exports
    class AttachForm < ApplicationForm
      CONTENT_TYPES = %w[application/pdf].freeze
      MAX_SIZE = 5.megabytes.freeze

      delegate :document,
               to: :reflection

      # validates :document,
      #           attached: true,
      #           content_type: CONTENT_TYPES,
      #           size: {less_than: MAX_SIZE}

      def document=(value)
        create_tmp_file(string_io: value.body, path: value.name) do |file|
          reflection.document.attach(io: file, filename: value.name)
        end
      end

      private

      def create_tmp_file(string_io:, path:)
        path = Rails.root.join('tmp', path)
        File.open(path, 'wb') { |file| file.write(string_io) }
        yield(File.new(path)) if block_given?
        File.delete(path) if File.exist?(path)
      end

      def save_reflection
        reflection.save!
      end
    end
  end
end
