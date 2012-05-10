require 'test_helper'

module PaginatedTable
  describe "configuration" do
    let(:configuration) { PaginatedTable.configuration }
    after do
      PaginatedTable.set_default_configuration
    end

    it "should have default rows_per_page" do
      configuration.rows_per_page.must_equal 10
    end

    it "should let us set rows_per_page" do
      PaginatedTable.configure do |config|
        config.rows_per_page = 20
      end
      configuration.rows_per_page.must_equal 20
    end
  end
end
