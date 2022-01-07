# -*- coding: utf-8 -*-
class LatexToPdf
  def self.config
    @config||={
      :recipe => [
      #  {
      #    :command => 'pdflatex',
      #    :arguments => ['-halt-on-error', '-shell-escape', '-interaction=batchmode'],
      #    :extra_arguments => [],
      #    :runs => 1
      #  }
      ],
      :command => 'pdflatex',
      :arguments => ['-halt-on-error'],
      :default_arguments => ['-shell-escape', '-interaction=batchmode'],
      workdir: ->() { "#{Process.pid}-#{Thread.current.hash}" },
      preservework: false,
      basedir: File.join(Rails.root, 'tmp', 'rails-latex'),
      :parse_runs => 1
    }
  end

  # Converts a string of LaTeX +code+ into a binary string of PDF.
  #
  # By default, pdflatex is used to convert the file and creates the directory
  # +#{Rails.root}/tmp/rails-latex/+ to store intermediate files.
  #
  # The config argument defaults to LatexToPdf.config but can be overridden
  # using @latex_config.
  def self.generate_pdf(code, config)
    config = self.config.merge(config)
    recipe = config[:recipe]

    # Deprecated legacy mode, if no recipe found
    if recipe.length == 0
      if config != self.config
        Rails.logger.warn("Using command, arguments and parse_runs is deprecated in favor of recipe")
      end
      # Regression fix -- ability to override some arguments (-halt-on-error) but not other (-interaction),
      #                   this is expected behaviour as seen in test_broken_doc_overriding_halt_on_error.
      #                   Will be fixed in rails-latex 3
      recipe = [{
        :command => config[:command],
        :arguments => config[:arguments] + config[:default_arguments],
        :runs => config[:parse_runs]
      }]
    end

    # Create directory, prepare additional supporting files (.cls, .sty, ...)
    dir = File.join(config[:basedir], config[:workdir].call)
    input = File.join(dir, 'input.tex')
    log   = File.join(dir, 'input.log')
    FileUtils.mkdir_p(dir)
    supporting = config[:supporting]
    if supporting.kind_of?(String) or supporting.kind_of?(Pathname) or (supporting.kind_of?(Array) and supporting.length > 0)
      FileUtils.cp_r(supporting, dir)
    end
    File.open(input,'wb') {|f| f.write(code)}

    # Process recipe
    recipe.each do |item|
      runs = item[:runs] || config[:parse_runs]
      command =  [item[:command] || config[:command]]
      command += item[:arguments] || config[:arguments] + config[:default_arguments]
      command += item[:extra_arguments].to_a + ['input']

      Rails.logger.info "Running '#{command.join(' ')}' in #{dir} #{runs} times..."

      (runs - 1).times do
        io = IO.popen(command, chdir: dir, err: [:child, :out])
        output = io.read
        io.close

        unless $?.exitstatus.zero?
          File.open(log, "a") do |f|
            f.write("#{command} failed with exit status #{$?.exitstatus}: #{output}")
          end

          break
        end
      end

    end

    # Finish
    if $?.exitstatus.zero? && File.exist?(pdf_file=input.sub(/\.tex$/,'.pdf'))
      cmd = config[:preservework] ? :cp : :mv
      FileUtils.send(cmd, input, File.join(config[:basedir], 'input.tex'))
      FileUtils.send(cmd, log, File.join(config[:basedir], 'input.log'))
      result = File.read(pdf_file)
      FileUtils.rm_rf(dir) unless config[:preservework]
    else
      raise RailsLatex::ProcessingError.new(
        "rails-latex failed: See #{log} for details",
        File.open(input).read,
        File.open(log).read
      )
    end
    result
  end

  # Escapes LaTex special characters in text so that they wont be interpreted as LaTex commands.
  #
  # This method will use RedCloth to do the escaping if available.
  def self.escape_latex(text)
    # :stopdoc:
    unless instance_variable_defined?(:@latex_escaper) && @latex_escaper
      if defined?(RedCloth::Formatters::LATEX)
        class << (@latex_escaper=RedCloth.new(''))
          include RedCloth::Formatters::LATEX
        end
      else
        class << (@latex_escaper=Object.new)
          ESCAPE_RE=/([{}_$&%#])|([\\^~|<>])/
          ESC_MAP={
            '\\' => 'backslash',
            '^' => 'asciicircum',
            '~' => 'asciitilde',
            '|' => 'bar',
            '<' => 'less',
            '>' => 'greater',
          }

          def latex_esc(text)   # :nodoc:
            text.gsub(ESCAPE_RE) {|m|
              if $1
                "\\#{m}"
              else
                "\\text#{ESC_MAP[m]}{}"
              end
            }
          end
        end
      end
      # :startdoc:
    end

    @latex_escaper.latex_esc(text.to_s.to_str).html_safe
  end
end
