require 'stache/handlebars/view'

module Stache
  module Handlebars
    # From HAML, thanks a bunch, guys!
    # In Rails 3.1+, template handlers don't inherit from anything. In <= 3.0, they do.
    # To avoid messy logic figuring this out, we just inherit from whatever the ERB handler does.
    class Handler < Stache::Util.av_template_class(:Handlers)::ERB.superclass
      if Stache::Util.needs_compilable?
        include Stache::Util.av_template_class(:Handlers)::Compilable
      end

      def self.context
        @context ||= ::Handlebars::Context.new
      end

      def compile(template)
        <<-RUBY_CODE
          handlebars = Stache::Handlebars::Handler.context

          template = handlebars.compile('#{template.source.gsub(/'/, "\\\\'")}')
          vars = {}
          vars.merge!(@_assigns)
          vars.merge!(local_assigns || {})

          template.call(vars).html_safe
        RUBY_CODE
      end

      # In Rails 3.1+, #call takes the place of #compile
      def self.call(template)
        new.compile(template)
      end
    end
  end
end
