require 'test_helper'

module PaginatedTable
  describe Page do
    let(:page) { Page.new(:number => 2, :rows => 5, :sort_column => 'name', :sort_direction => 'desc') }

    it "has a page number" do
      page.number.must_equal 2
    end

    it "does not accept a negative page number" do
      lambda { Page.new(:number => -1) }.must_raise ArgumentError
    end

    it "does not accept a zero page number" do
      lambda { Page.new(:number => 0) }.must_raise ArgumentError
    end

    it "does not accept an invalid page number" do
      lambda { Page.new(:number => 'foo') }.must_raise ArgumentError
    end

    it "has a rows number" do
      page.rows.must_equal 5
    end

    it "does not accept a negative number of rows" do
      lambda { Page.new(:rows => -1) }.must_raise ArgumentError
    end

    it "does not accept a zero number of rows "do
      lambda { Page.new(:rows => 0) }.must_raise ArgumentError
    end

    it "does not accept an invalid page number" do
      lambda { Page.new(:rows => 'foo') }.must_raise ArgumentError
    end

    it "has a sort column" do
      page.sort_column.must_equal 'name'
    end

    it "has a sort direction" do
      page.sort_direction.must_equal 'desc'
    end

    it "does not accept an invalid sort direction" do
      lambda { Page.new(:sort_direction => 'foo') }.must_raise ArgumentError
    end

    describe ".opposite_sort_direction" do
      it "returns asc for desc" do
        Page.opposite_sort_direction('asc').must_equal 'desc'
      end

      it "returns desc for asc" do
        Page.opposite_sort_direction('desc').must_equal 'asc'
      end
    end

    describe "#page_for_number" do
      describe "with a new page number" do
        let(:number_page) { page.page_for_number(3) }

        it "returns a new page with the new page number" do
          number_page.number.must_equal 3
        end

        it "returns a new page with the same number of rows" do
          number_page.rows.must_equal 5
        end

        it "returns a new page with the same sort column" do
          number_page.sort_column.must_equal 'name'
        end

        it "returns a new page with the same sort direction" do
          number_page.sort_direction.must_equal 'desc'
        end
      end
    end

    describe "#page_for_sort_column" do
      describe "on a new sort column" do
        let(:sort_page) { page.page_for_sort_column('title') }

        it "returns a new page with page number 1" do
          sort_page.number.must_equal 1
        end

        it "returns a new page with the same number of rows" do
          sort_page.rows.must_equal 5
        end

        it "returns a new page with the given sort column" do
          sort_page.sort_column.must_equal 'title'
        end

        it "returns a new page with sort direction asc" do
          sort_page.sort_direction.must_equal 'asc'
        end
      end

      describe "on the same sort column" do
        let(:sort_page) { page.page_for_sort_column('name') }

        it "returns a new page with page number 1" do
          sort_page.number.must_equal 1
        end

        it "returns a new page with the same number of rows" do
          sort_page.rows.must_equal 5
        end

        it "returns a new page with the same sort column" do
          sort_page.sort_column.must_equal 'name'
        end

        it "returns a new page with the opposite sort direction" do
          sort_page.sort_direction.must_equal 'asc'
          sort_page.page_for_sort_column('name').sort_direction.must_equal 'desc'
        end
      end
    end
  end
end
