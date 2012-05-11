require 'test_helper'

module PaginatedTable
  describe DataPage do
    describe "#data" do
      let(:page) {
        Page.new(
          :number => 2,
          :rows => 5,
          :sort_column => 'name',
          :sort_direction => 'asc'
        )
      }
      let(:collection) {
        collection = (1..10).map { |i| "Name #{i}" }
        def collection.order(clause)
          raise unless clause == "name asc"
          sort
        end
        collection
      }

      it "sorts the collection and pages to the given page number" do
        DataPage.new(collection, page).data.must_equal(
          ["Name 5", "Name 6", "Name 7", "Name 8", "Name 9"]
        )
      end

      describe "#page" do
        it "provides a reference to the given page" do
          DataPage.new(collection, page).page.must_equal page
        end
      end
    end
  end
end
