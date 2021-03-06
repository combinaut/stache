module Stache
  module ViewContext
    def self.current
      Thread.current[:current_view_context]
    end

    def self.current=(input)
      Thread.current[:current_view_context] = input
    end
  end

  module ViewContextFilter
    def set_current_view_context
      Stache::ViewContext.current = self.view_context
    end

    def self.included(source)
      source.send(:before_action, :set_current_view_context) if source.respond_to?(:before_filter)
    end
  end
end
