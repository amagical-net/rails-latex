class LatexExampleController < ApplicationController
  def index
  end

  def barcode
    render layout: 'barcode'
  end
end
