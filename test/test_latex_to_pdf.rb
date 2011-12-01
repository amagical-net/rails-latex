require 'helper'
require 'rails-latex/erb_latex'
require 'ostruct'

Rails=OpenStruct.new(:root => TMP_DIR=File.expand_path("../tmp",__FILE__))

class TestLatexToPdf < Test::Unit::TestCase
  def teardown
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

  def test_generate_pdf_one_parse
    pdf_file=write_pdf do
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_doc.tex',__FILE__)),{})
    end
    assert_equal "The last page is ??.\n\n1\n\n\f", `pdftotext #{pdf_file} -`

    assert_equal ["#{TMP_DIR}/rails-latex/input.log"], Dir["#{TMP_DIR}/rails-latex/*"]
  end

  def test_generate_pdf_two_parse
    pdf_file=write_pdf do
      LatexToPdf.config[:parse_twice]=true
      LatexToPdf.generate_pdf(IO.read(File.expand_path('../test_doc.tex',__FILE__)),{})
    end
    assert_equal "The last page is 1.\n\n1\n\n\f", `pdftotext #{pdf_file} -`

    assert_equal ["#{TMP_DIR}/rails-latex/input.log"], Dir["#{TMP_DIR}/rails-latex/*"]
  end

end
