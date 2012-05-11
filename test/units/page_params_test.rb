require 'test_helper'

module PaginatedTable
  describe PageParams do
    describe ".create_page" do
      it "returns a new page created from the request params" do
        page = PageParams.create_page(
          :page => '2',
          :per_page => '5',
          :sort_column => 'name',
          :sort_direction => 'desc'
        )
        page.number.must_equal 2
        page.rows.must_equal 5
        page.sort_column.must_equal 'name'
        page.sort_direction.must_equal 'desc'
      end

      it "returns a new page created from the request params and the defaults" do
        page = PageParams.create_page(
          { :page => '2', :per_page => '5' },
          { :sort_column => 'name', :sort_direction => 'desc' }
        )
        page.number.must_equal 2
        page.rows.must_equal 5
        page.sort_column.must_equal 'name'
        page.sort_direction.must_equal 'desc'
      end
    end

    describe ".to_params" do
      it "creates a params hash from the page" do
        page = Page.new(
          :number => 2,
          :rows => 5,
          :sort_column => 'name',
          :sort_direction => 'desc'
        )
        PageParams.to_params(page).must_equal(
          :page => '2',
          :per_page => '5',
          :sort_column => 'name',
          :sort_direction => 'desc'
        )
      end
    end
  end
end
