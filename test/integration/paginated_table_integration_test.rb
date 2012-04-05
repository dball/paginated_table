require 'test_helper'
require 'capybara/webkit'

describe "paginated_table integration" do

  describe "rendering" do
    before do
      visit "/data"
    end

    it "displays a pagination area" do
      page.has_xpath?(pagination_xpath).must_equal true
    end

    it "displays a paginated table" do
      page.has_xpath?(table_xpath).must_equal true
    end

    it "displays Name in the first column header" do
      page.has_xpath?("#{th_xpath(1)}[.='Name']").must_equal true
    end

    it "displays the data names in the first column" do
      (1..10).each do |row|
        page.has_xpath?("#{tr_xpath(row)}/td[1][.='Name #{row}']").must_equal true
      end
    end

    it "displays links to the data in the second column" do
      (1..10).each do |row|
        page.has_xpath?("#{tr_xpath(row)}/td[2]/a[@href='/data/#{row}'][.='#{row}']").must_equal true
      end
    end
  end

  describe "javascript spike" do
    #it "displays to the console" do
    #  Capybara.current_driver = Capybara.javascript_driver
    #  visit "/data"
    #  page.driver.console_messages.map { |m| m[:message] }.must_equal %w(foobar)
    #end
  end

  describe "pagination" do
    it "displays one page of results" do
      visit "/data"
      pagination_info_text.must_equal "Displaying data controller/data 1 - 10 of 100 in total"
    end

    it "follows the link to the second page of results" do
      visit "/data"
      click_link "2"
      pagination_info_text.must_equal "Displaying data controller/data 11 - 20 of 100 in total"
    end
  end

  def pagination_xpath
    "//div[@class='pagination']"
  end

  def pagination_header_xpath
    "#{pagination_xpath}/div[@class='header']"
  end

  def pagination_info_xpath
    "#{pagination_header_xpath}/div[@class='info']"
  end

  def table_xpath
    "#{pagination_xpath}/table[@class='paginated']"
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

  def pagination_info_text
    info = find(:xpath, pagination_info_xpath)
    replace_nbsp(info.text)
  end

  def replace_nbsp(str)
    if str.respond_to?(:valid_encoding?)
      str.force_encoding('UTF-8').gsub(/\xc2\xa0/u, ' ')
    else
      str.gsub(/\xc2\xa0/u, ' ')
    end
  end
end
