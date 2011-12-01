class LatexExampleController < ApplicationController
  def index
  end

  def barcode
    render :layout => 'barcode'
  end

  def barcode_as_string
    old_formats = formats
    self.formats = ['pdf']
    @pdf=render_to_string(action: 'barcode', layout: "barcode")
    File.open(file="#{Rails.root}/tmp/a.pdf",'w:binary') do |io|
      io.write(@pdf)
    end
    self.formats = old_formats
    render text: "wrote #{file}"
  end
end
