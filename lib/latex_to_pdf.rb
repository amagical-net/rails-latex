class LatexToPdf
  # Converts a string of LaTeX +code+ into a binary string of PDF.
  #
  # pdflatex is used to convert the file and creates the directory +#{Rails.root}/tmp/rails-latex+ to store intermediate
  # files.
  def self.generate_pdf(code,parse_twice=false)
    dir=File.join(Rails.root,'tmp','rails-latex',"#{Process.pid}-#{Thread.current.hash}")
    input=File.join(dir,'input.tex')
    FileUtils.mkdir_p(dir)
    File.open(input,'wb') {|io| io.write(code) }
    (parse_twice ? 2 : 1).times {
      system('pdflatex','-output-directory',dir,'-interaction','batchmode',input)
# :umask => 7,:out => :close, :err => :close, :in => :close) # not supported in ruby 1.8
    }
    FileUtils.mv(input.sub(/\.tex$/,'.log'),File.join(dir,'..','input.log'))
    if File.exist?(pdf_file=input.sub(/\.tex$/,'.pdf'))
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
