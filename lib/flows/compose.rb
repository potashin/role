module Flows
  class Compose
    def initialize(*actions)
      @actions = actions
    end

    def call(*initial_args)
      @actions.inject(initial_args) do |current_args, action|
        process_action(current_args, action)
      end
    end

    private

    def process_action(args, action)
      case args
      when Array
        kwargs = args.extract_options!
        action.call(*args, **kwargs)
      when Hash
        action.call(**args)
      else
        action.call(args)
      end
    end
  end
end
