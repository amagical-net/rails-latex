# -*- coding: utf-8 -*-
require 'fileutils'
require 'rails-latex/latex_to_pdf'
require 'action_view'

module ActionView               # :nodoc: all
  module Template::Handlers
    class ERBLatex < ERB
      def self.call(template)
        new.compile(template)
      end

      def compile(template)
        erb = "<% __in_erb_template=true %>#{template.source}"
        out=self.class.erb_implementation.new(erb, :trim=>(self.class.erb_trim_mode == "-")).src
        out + ";LatexToPdf.generate_pdf(@output_buffer.to_s,@latex_config||{},@latex_parse_twice)"
      end
    end
  end
  Template.register_template_handler :erbtex, Template::Handlers::ERBLatex
end

