class LatexToPdf
  def self.config
    @config||={:command => 'pdflatex', :arguments => ['-halt-on-error'], :parse_twice => false, :parse_runs => 1}
  end

  # Converts a string of LaTeX +code+ into a binary string of PDF.
  #
  # pdflatex is used to convert the file and creates the directory +#{Rails.root}/tmp/rails-latex/+ to store intermediate
  # files.
  #
  # The config argument defaults to LatexToPdf.config but can be overridden using @latex_config.
  #
  # The parse_twice argument and using config[:parse_twice] is deprecated in favor of using config[:parse_runs] instead.
  def self.generate_pdf(code,config,parse_twice=nil)
    config=self.config.merge(config)
    parse_twice=config[:parse_twice] if parse_twice.nil? # deprecated
    parse_runs=[config[:parse_runs], (parse_twice ? 2 : config[:parse_runs])].max
    puts "Running Latex #{parse_runs} times..."
    dir=File.join(Rails.root,'tmp','rails-latex',"#{Process.pid}-#{Thread.current.hash}")
    input=File.join(dir,'input.tex')
    FileUtils.mkdir_p(dir)
    # copy any additional supporting files (.cls, .sty, ...)
    supporting = config[:supporting]
    if supporting.class == String or supporting.class == Array and supporting.length > 0
      FileUtils.cp(supporting, dir)
    end
    File.open(input,'wb') {|io| io.write(code) }
    Process.waitpid(
      fork do
        begin
          Dir.chdir dir
          original_stdout, original_stderr = $stdout, $stderr
          $stderr = $stdout = File.open("input.log","a")
          args=config[:arguments] + %w[-shell-escape -interaction batchmode input.tex]
          (parse_runs-1).times do
            system config[:command],'-draftmode',*args
          end
          exec config[:command],*args
        rescue
          File.open("input.log",'a') {|io|
            io.write("#{$!.message}:\n#{$!.backtrace.join("\n")}\n")
          }
        ensure
          $stdout, $stderr = original_stdout, original_stderr
          Process.exit! 1
        end
      end)
    if File.exist?(pdf_file=input.sub(/\.tex$/,'.pdf'))
      FileUtils.mv(input.sub(/\.tex$/,'.log'),File.join(dir,'..','input.log'))
      result=File.read(pdf_file)
      FileUtils.rm_rf(dir)
    else
      raise "pdflatex failed: See #{input.sub(/\.tex$/,'.log')} for details"
    end
    result
  end

  # Escapes LaTex special characters in text so that they wont be interpreted as LaTex commands.
  #
  # This method will use RedCloth to do the escaping if available.
  def self.escape_latex(text)
    # :stopdoc:
    unless @latex_escaper
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

    @latex_escaper.latex_esc(text.to_s).html_safe
  end
end
