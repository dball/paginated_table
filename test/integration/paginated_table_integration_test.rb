require 'test_helper'

describe "paginated_table integration" do

  it "renders a paginated table" do
    visit "/data"
    page.has_xpath?(table_xpath).must_equal true
  end

  it "renders the first page of results" do
    visit "/data"
    page.has_xpath?(tr_xpath(10)).must_equal true
    page.has_xpath?(tr_xpath(11)).must_equal false
  end

  it "renders the data names in the first column" do
    visit "/data"
    (1..10).each do |row|
      page.has_xpath?("#{tr_xpath(row)}/td[1][.='Name #{row}']").must_equal true
    end
  end

  it "renders links to the data in the second column" do
    visit "/data"
    (1..10).each do |row|
      page.has_xpath?("#{tr_xpath(row)}/td[2]/a[@href='/data/#{row}'][.='#{row}']").must_equal true
    end
  end

  def table_xpath
    "//table[@class='paginated']"
  end

  def tbody_xpath
    "#{table_xpath}/tbody[1]"
  end

  def tr_xpath(row)
    "#{tbody_xpath}/tr[#{row}]"
  end

end
