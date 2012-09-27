class LatexExampleController < ApplicationController
  def index
  end

  def barcode
    render :layout => 'barcode', formats: [:pdf]
  end

  def barcode_as_string
    @pdf=render_to_string(action: 'barcode', layout: "barcode", formats: [:pdf])
    self.content_type = 'text/html'

    File.open(file="#{Rails.root}/tmp/a.pdf",'w:binary') do |io|
      io.write(@pdf)
    end

    render text: "wrote #{file}"
  end
end
