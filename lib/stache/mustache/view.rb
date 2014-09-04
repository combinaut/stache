require 'mustache'

module Stache
  module Mustache
    #
    # A Convienent Base Class for the views. Subclass this for autoloading magic with your templates.
    class View < ::Mustache
      attr_accessor :view, :virtual_path

      def method_missing(method, *args, &block)
        view.send(method, *args, &block)
      end

      def respond_to?(method, include_private=false)
        super(method, include_private) || view.respond_to?(method, include_private)
      end

      def virtual_path=(path)
        @virtual_path = path
        #
        # Since the addition to the lookup_context only depends on the virtual_path,
        # do it here instead of inside the partial.
        #
        current_dir   = Stache.template_base_path.join(path.split("/")[0..-2].join("/"))
        lookup_context.view_paths << current_dir unless lookup_context.view_paths.include?(current_dir)
      end

      # Redefine where Stache::View templates locate their partials
      def partial(name)
        # Try to resolve the partial template
        begin
          template_finder(name, true)
        rescue ActionView::MissingTemplate
          template_finder(name, false)
        end.source
      end

      def helpers
        self.class.helpers
      end
      alias :h :helpers

      class << self
        def helpers
          Stache::ViewContext.current
        end
        alias :h :helpers
      end

    protected
      def template_finder(name, partial)
        if ActionPack::VERSION::MAJOR == 3 && ActionPack::VERSION::MINOR < 2
          lookup_context.find(name, [], partial)
        else # Rails 3.2 and higher
          lookup_context.find(name, [], partial, [], { formats: [:html], handlers: [:mustache] })
        end
      end

    end
  end
end
