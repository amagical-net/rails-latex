module RailsLatex
  class ProcessingError < StandardError
    attr_reader :src, :log
    def initialize(msg = 'RailsLatex processing failed.', src = '', log = '')
      @src = src
      @log = log
      super(msg)
    end
  end
end
