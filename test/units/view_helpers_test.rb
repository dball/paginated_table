require 'test_helper'

module PaginatedTable
  describe ViewHelpers do
    let(:view) {
      view = Object.new
      view.send(:extend, ViewHelpers)
      view
    }
    let(:collection) { stub("collection") }
    let(:results) { stub("results") }

    describe "#paginated_table" do
      it "delegates to Handler with the default arguments" do
        Handler.expects(:handle).
          with(view, TableDescription, RendersTable, collection).
          returns(results)
        view.paginated_table(collection).must_equal results
      end

      it "accepts a :describer option" do
        describer_class = stub("describer")
        Handler.expects(:handle).
          with(view, describer_class, RendersTable, collection).
          returns(results)
        view.paginated_table(collection, :describer => describer_class).must_equal results
      end

      it "accepts a :renderer option" do
        renderer_class = stub("renderer")
        Handler.expects(:handle).
          with(view, TableDescription, renderer_class, collection).
          returns(results)
        view.paginated_table(collection, :renderer => renderer_class).must_equal results
      end
    end
  end

  describe Handler do
    describe ".handle" do
      let(:view) { stub("view") }
      let(:collection) { stub("collection") }
      let(:describer_class) { stub("describer", :new => description) }
      let(:renderer_class) { stub("renderer", :new => renderer) }
      let(:description) { stub("description") }
      let(:renderer) { stub("renderer", :render => results) }
      let(:results) { stub("results") }

      it "constructs a new description" do
        describer_class.expects(:new).with().returns(description)
        Handler.handle(view, describer_class, renderer_class, collection) { |b| }
      end

      it "yields the description once to its block" do
        yielded_args = []
        Handler.handle(view, describer_class, renderer_class, collection) do |block_arg|
          yielded_args << block_arg
        end
        yielded_args.must_equal [description]
      end

      it "constructs a new renderer with the view, description, and collection" do
        renderer_class.expects(:new).with(view, description, collection).returns(renderer)
        Handler.handle(view, describer_class, renderer_class, collection) { |b| }
      end

      it "returns the results of calling render on the renderer" do
        Handler.handle(view, describer_class, renderer_class, collection) { |b| }.
          must_equal results
      end
    end
  end

  describe TableDescription do
    describe "#initialize" do
      it "creates a new instance with empty columns" do
        TableDescription.new.columns.must_equal []
      end
    end

    describe "#column" do
      it "constructs a new Column and appends it to the columns array" do
        column = stub("column")
        TableDescription::Column.stubs(:new).with(:foo).returns(column)
        description = TableDescription.new
        description.column(:foo)
        description.columns.must_equal [column]
      end
    end
  end

  describe TableDescription::Column do
    describe "#initialize" do
      it "creates a new instance with a name and an optional block" do
        TableDescription::Column.new(:foo) { true }
      end
    end

    describe "#render_header" do
      it "returns the titleized name" do
        TableDescription::Column.new(:foo).render_header.must_equal "Foo"
      end
    end

    describe "#render_cell" do
      let(:results) { stub("results") }

      describe "on a column with no block" do
        let(:column) { TableDescription::Column.new(:foo) }

        it "sends its name to the datum" do
          datum = stub("datum", :foo => results)
          column.render_cell(datum).must_equal results
        end
      end

      describe "on a column with a block" do
        it "calls its block with the datum" do
          datum = stub("datum")
          column = TableDescription::Column.new(:foo) do |block_arg|
            results if block_arg == datum
          end
          column.render_cell(datum).must_equal results
        end
      end
    end
  end
end
