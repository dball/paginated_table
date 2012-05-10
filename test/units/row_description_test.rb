require 'test_helper'

module PaginatedTable
  describe RowDescription do
    let(:table) { TableDescription.new }
    let(:description_proc) { lambda { |row| nil } }
    let(:options) { {} }
    let(:description) {
      RowDescription.new(table, options, description_proc)
    }

    describe "#initialize" do
      it "creates a new instance with empty columns" do
        description.columns.must_equal []
      end

      it "calls the given block with itself" do
        fake_proc = stub("proc")
        fake_proc.expects(:call)
        RowDescription.new(table, options, fake_proc)
      end
    end

    describe "#title" do
      it "returns the title option" do
        options[:title] = title = stub("title")
        description.title.must_equal title
      end
    end

    describe "#cycle" do
      it "returns the cycle option" do
        options[:cycle] = cycle = stub("cycle")
        description.cycle.must_equal cycle
      end
    end

    describe "#hidden" do
      it "returns the hidden option" do
        options[:hidden] = hidden = stub("hidden")
        description.hidden.must_equal hidden
      end
    end

    describe "#data_type" do
      it "returns the data_type option" do
        options[:data_type] = data_type = stub("data_type")
        description.data_type.must_equal data_type
      end
    end

    describe "#colspan" do
      it "delegates to the table description" do
        colspan = stub("colspan")
        arg = stub("arg")
        table.stubs(:colspan).with(arg).returns(colspan)
        description.colspan(arg).must_equal colspan
      end
    end

    describe "#column" do
      it "constructs a new ColumnDescription and appends it to the columns array" do
        column = stub("column")
        name = stub("name")
        ColumnDescription.stubs(:new).with(description, name).returns(column)
        description.column(name)
        description.columns.must_equal [column]
      end
    end
  end
end
