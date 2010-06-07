require 'fileutils'
require 'latex_to_pdf'
require 'action_view'

module ActionView               # :nodoc: all
  module Template
    module Handlers
      class ERBLatex < ERB
        def compile(template)
          erb = "<% __in_erb_template=true %>#{template.source}"
          out=self.class.erb_implementation.new(erb, :trim=>(self.class.erb_trim_mode == "-")).src
          out + ";LatexToPdf.generate_pdf(@output_buffer.to_s)"
        end
      end
    end
    register_template_handler :erbtex, ERBLatex
  end
end


