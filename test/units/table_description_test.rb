require 'test_helper'

module PaginatedTable
  describe TableDescription do
    let(:description) { TableDescription.new }

    describe "#column" do
      let(:row) { row = stub("row", :column => nil) }

      before do
        RowDescription.stubs(:new => row)
      end

      describe "when first called in a table description" do
        it "creates a new row" do
          description.column
          description.rows.must_equal [row]
        end

        it "calls column on the row" do
          args = [stub("arg1"), stub("arg2")]
          row.expects(:column).with(*args)
          description.column(*args)
        end
      end

      describe "when subsequently called in a table description" do
        before do
          description.column
        end

        it "does not create a new row" do
          description.expects(:row).never
          description.column
        end

        it "calls column on the default row" do
          args = [stub("arg1"), stub("arg2")]
          row.expects(:column).with(*args)
          description.column(*args)
        end
      end

      describe "when called after row has been called by a table description" do
        before do
          description.row
        end

        it "raises TableDescription::Invalid" do
          lambda { description.column }.must_raise TableDescription::Invalid
        end
      end

    end

    describe "#row" do
      it "constructs a new RowDescription and appends it to the rows array" do
        row = stub("row")
        options = stub("options")
        RowDescription.stubs(:new).with(options, nil).returns(row)
        description.row(options)
        description.rows.must_equal [row]
      end
    end
  end
end
