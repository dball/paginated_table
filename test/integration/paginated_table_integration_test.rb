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

    it "displays Raw in the third column header" do
      page.has_xpath?("#{th_xpath(3)}[.='Raw']").must_equal true
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

    describe "with javascript" do
      before do
        Capybara.current_driver = Capybara.javascript_driver
      end

      it "updates only the pagination table from pagination table links" do
        visit "/data"
        click_link "2"
        wait_for_ajax_request
        page.has_xpath?("//h1[2]").must_equal false
      end
    end
  end

  describe "pagination" do
    describe "without javascript" do
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

    describe "with javascript" do
      before do
        Capybara.current_driver = Capybara.javascript_driver
      end

      it "displays one page of results" do
        visit "/data"
        pagination_info_text.must_equal "Displaying data controller/data 1 - 10 of 100 in total"
      end

      it "follows the link to the second page of results" do
        visit "/data"
        click_link "2"
        wait_for_ajax_request
        pagination_info_text.must_equal "Displaying data controller/data 11 - 20 of 100 in total"
      end

      # Ensures the AJAX content is decorated with event handlers
      it "follows the link to the fourth page, then back to the third page" do
        visit "/data"
        click_link "4"
        wait_for_ajax_request
        pagination_info_text.must_equal "Displaying data controller/data 31 - 40 of 100 in total"
        click_link "3"
        wait_for_ajax_request
        pagination_info_text.must_equal "Displaying data controller/data 21 - 30 of 100 in total"
      end
    end
  end

  describe "sorting" do
    describe "decoration" do
      it "marks the sortable columns" do
        visit "/data"
        page.has_xpath?("#{th_xpath(1)}[@class='sortable'][.='Name']").must_equal true
      end

      it "marks the sort column when sorted in ascending order" do
        visit "/data"
        click_link "Name"
        page.has_xpath?("#{th_xpath(1)}[@class='sortable sorted_asc'][.='Name']").must_equal true
      end

      it "marks the sort column when sorted in descending order" do
        visit "/data"
        click_link "Name"
        click_link "Name"
        page.has_xpath?("#{th_xpath(1)}[@class='sortable sorted_desc'][.='Name']").must_equal true
      end
    end

    describe "without javascript" do
      it "follows the link to sort the first column in ascending order" do
        visit "/data"
        click_link "Name"
        [1, 10, 100, 11, 12, 13, 14, 15, 16, 17].each_with_index do |row, i|
          page.has_xpath?("#{tr_xpath(i + 1)}/td[1][.='Name #{row}']").must_equal true
        end
      end

      it "follows the link to sort the first column twice in descending order" do
        visit "/data"
        click_link "Name"
        click_link "Name"
        [99, 98, 97, 96, 95, 94, 93, 92, 91, 90].each_with_index do |row, i|
          page.has_xpath?("#{tr_xpath(i + 1)}/td[1][.='Name #{row}']").must_equal true
        end
      end

      it "follows the link to sort the first column, then to the second page" do
        visit "/data"
        click_link "Name"
        click_link "2"
        [18, 19, 2, 20, 21, 22, 23, 24, 25, 26].each_with_index do |row, i|
          page.has_xpath?("#{tr_xpath(i + 1)}/td[1][.='Name #{row}']").must_equal true
        end
      end

      it "has no link to sort the second column" do
        visit "/data"
        page.has_xpath?("a[.='Link']").must_equal false
      end
    end

    describe "with javascript" do
      before do
        Capybara.current_driver = Capybara.javascript_driver
      end

      it "follows the link to sort the first column in ascending order" do
        visit "/data"
        click_link "Name"
        wait_for_ajax_request
        [1, 10, 100, 11, 12, 13, 14, 15, 16, 17].each_with_index do |row, i|
          page.has_xpath?("#{tr_xpath(i + 1)}/td[1][.='Name #{row}']").must_equal true
        end
      end

      it "follows the link to sort the first column twice in descending order" do
        visit "/data"
        click_link "Name"
        wait_for_ajax_request
        click_link "Name"
        wait_for_ajax_request
        [99, 98, 97, 96, 95, 94, 93, 92, 91, 90].each_with_index do |row, i|
          page.has_xpath?("#{tr_xpath(i + 1)}/td[1][.='Name #{row}']").must_equal true
        end
      end

      it "follows the link to sort the first column, then to the second page" do
        visit "/data"
        click_link "Name"
        wait_for_ajax_request
        click_link "2"
        wait_for_ajax_request
        [18, 19, 2, 20, 21, 22, 23, 24, 25, 26].each_with_index do |row, i|
          page.has_xpath?("#{tr_xpath(i + 1)}/td[1][.='Name #{row}']").must_equal true
        end
      end
    end
  end

  def pagination_xpath
    "//div[@class='paginated_table']"
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

  def wait_for_ajax_request
    wait_until do
      page.evaluate_script('jQuery.active') == 0
    end
  end
end
