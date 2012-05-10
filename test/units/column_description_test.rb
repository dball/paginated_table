require 'test_helper'

module PaginatedTable
  describe ColumnDescription do
    describe "#initialize" do
      it "creates a new instance with a name and an optional block" do
        ColumnDescription.new(:foo) { true }
      end

      it "accepts an options hash" do
        ColumnDescription.new(:foo, :baz => 'bat')
      end
    end

    describe "#sortable?" do
      it "returns true by default" do
        ColumnDescription.new(:foo).sortable?.must_equal true
      end

      it "returns false if the :sortable option is false" do
        ColumnDescription.new(:foo, :sortable => false).sortable?.must_equal false
      end
    end

    describe "#html_attributes" do
      it "returns an empty hash by default" do
        ColumnDescription.new(:foo).html_attributes.must_equal({})
      end

      it "adds the css classes given by the :class option" do
        ColumnDescription.new(:foo, :class => %w(bar baz)).
          html_attributes.must_equal({ :class => 'bar baz' })
      end

      it "adds the css styles given by the :style option" do
        ColumnDescription.new(:foo, :style => 'font-face: bold').
          html_attributes.must_equal({ :style => 'font-face: bold' })
      end
    end

    describe "#render_header" do
      it "returns the titleized name" do
        ColumnDescription.new(:foo).render_header.must_equal "Foo"
      end

      it "returns the :title option if given" do
        ColumnDescription.new(:foo, :title => 'bar').
          render_header.must_equal "bar"
      end
    end

    describe "#render_cell" do
      let(:results) { stub("results") }

      describe "on a column with no block" do
        let(:column) { ColumnDescription.new(:foo) }

        it "sends its name to the datum" do
          datum = stub("datum", :foo => results)
          column.render_cell(datum).must_equal results
        end
      end

      describe "on a column with a block" do
        it "calls its block with the datum" do
          datum = stub("datum")
          column = ColumnDescription.new(:foo) do |block_arg|
            results if block_arg == datum
          end
          column.render_cell(datum).must_equal results
        end
      end
    end
  end
end
