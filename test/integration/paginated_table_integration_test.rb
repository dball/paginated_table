require 'test_helper'

describe "paginated_table integration" do

  it "renders the first page of data in a table" do
    visit "/data"
    page.body.must_include '<table>'
  end

end
