# -*- coding: utf-8 -*-
require 'rails-latex/erb_latex'
require 'rails-latex/errors'
require 'ostruct'
require 'pathname'
require 'logger'

class TestLatexToPdf < Minitest::Test
  def setup
    super
    FileUtils.rm_rf("#{TMP_DIR}/tmp/rails-latex")
  end

  def teardown
    super
    LatexToPdf.instance_eval { @config=nil }
  end

  def write_pdf
    FileUtils.mkdir_p(TMP_DIR)
    pdf_file=File.join(TMP_DIR,'out.pdf')
    File.delete(pdf_file) if File.exist?(pdf_file)
    File.open(pdf_file,'wb') do |wio|
      wio.write(yield)
    end
    pdf_file
  end

  def test_escape
    assert_equal "dsf \\textless{} \\textgreater{} \\& ! @ \\# \\$ \\% \\textasciicircum{} \\textasciitilde{} \\textbackslash{} fds", LatexToPdf.escape_latex('dsf < > & ! @ # $ % ^ ~ \\ fds')
    LatexToPdf.instance_eval{@latex_escaper=nil}
    require 'redcloth'
    assert_equal "dsf \\textless{} \\textgreater{} \\& ! @ \\# \\$ \\% \\^{} \\~{} \\textbackslash{} fds", LatexToPdf.escape_latex('dsf < > & ! @ # $ % ^ ~ \\ fds')
  end

  def test_broken_doc
    begin
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_broken_doc.tex',__FILE__)),{})
      fail "Should throw exception"
    rescue => e
      assert(/^rails-latex failed: See / =~ e.message)
      assert(/! Undefined control sequence./ =~ e.log)
    end
  end

  def test_broken_doc_on_page_2
    begin
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_broken_doc_on_page_2.tex',__FILE__)),{:recipe => [
        { :command => 'xelatex', :runs => 2 }
      ]})
      fail "Should throw exception"
    rescue => e
      assert(/^rails-latex failed: See / =~ e.message)
      assert(/! Argument of \\hyper@n@rmalise has an extra }\./ =~ e.log)
    end
  end

  def test_generate_pdf_one_parse
    pdf_file=write_pdf do
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_doc.tex',__FILE__)),{})
    end
    assert_match /The last page is \?\?\.\s*1\s*\f/, `pdftotext #{pdf_file} -`

    assert_equal ["#{TMP_DIR}/tmp/rails-latex/input.log"], Dir["#{TMP_DIR}/tmp/rails-latex/*.log"]
  end

  def test_generate_pdf_parse_runs
    pdf_file=write_pdf do
      LatexToPdf.config[:parse_runs]=2
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_doc.tex',__FILE__)),{})
    end
    assert_match /The last page is 1\.\s*1\s*\f/, `pdftotext #{pdf_file} -`

    assert_equal ["#{TMP_DIR}/tmp/rails-latex/input.log"], Dir["#{TMP_DIR}/tmp/rails-latex/*.log"]
  end

  def test_doc_log_written
    begin
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_doc.tex',__FILE__)),{})
      assert_equal ["#{TMP_DIR}/tmp/rails-latex/input.log"], Dir["#{TMP_DIR}/tmp/rails-latex/*.log"]
      assert( File.read("#{TMP_DIR}/tmp/rails-latex/input.log") =~ /entering extended mode/ )
    end
  end

  def test_custom_recipe
    begin
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_doc.tex',__FILE__)),{:recipe => [
        { :command => 'pdflatex', :extra_arguments => ['-draftmode'] },
        { :command => 'bibtex', :arguments => [] },
        { :command => 'pdflatex', :runs => 2 }
      ]})
    end
  end

end
