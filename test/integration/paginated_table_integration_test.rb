require 'test_helper'

describe "paginated_table integration" do

  describe "rendering" do
    before do
      visit "/data"
    end

    it "renders a paginated table" do
      page.has_xpath?(table_xpath).must_equal true
    end

    it "renders Name in the first column header" do
      page.has_xpath?("#{th_xpath(1)}[.='Name']").must_equal true
    end

    it "renders the data names in the first column" do
      (1..10).each do |row|
        page.has_xpath?("#{tr_xpath(row)}/td[1][.='Name #{row}']").must_equal true
      end
    end

    it "renders links to the data in the second column" do
      (1..10).each do |row|
        page.has_xpath?("#{tr_xpath(row)}/td[2]/a[@href='/data/#{row}'][.='#{row}']").must_equal true
      end
    end
  end

  describe "pagination" do
    it "renders one page of results" do
      visit "/data"
      page.has_xpath?(tr_xpath(10)).must_equal true
      page.has_xpath?(tr_xpath(11)).must_equal false
    end
  end

  def table_xpath
    "//table[@class='paginated']"
  end

  def th_xpath(column)
    "#{table_xpath}/thead/tr[1]/th[#{column}]"
  end

  def tbody_xpath
    "#{table_xpath}/tbody[1]"
  end

  def tr_xpath(row)
    "#{tbody_xpath}/tr[#{row}]"
  end
end
