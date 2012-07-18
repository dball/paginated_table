require 'test_helper'

module PaginatedTable
  module View
    describe ColumnDescription do
      let(:options) { {} }
      let(:row) { stub("row") }
      let(:name) { 'foo' }
      let(:description) { ColumnDescription.new(row, name, options) }

      describe "#initialize" do
        it "creates a new instance with a row, a name and an optional block" do
          ColumnDescription.new(row, name) { true }
        end

        it "accepts an options hash" do
          ColumnDescription.new(row, name, :baz => 'bat')
        end
      end

      describe "#sortable?" do
        it "returns true by default" do
          description.must_be :sortable?
        end

        it "returns the :sortable option" do
          options[:sortable] = false
          description.wont_be :sortable?
        end
      end

      describe "#filterable?" do
        it "returns false by default" do
          description.wont_be :filterable?
        end

        it "returns true if anything was passed in the :filter option" do
          options[:filter] = stub("filters")
          description.must_be :filterable?
        end
      end

      describe "#span" do
        it "returns false by default" do
          description.span.must_equal false
        end

        it "returns the :span option" do
          options[:span] = span = stub("span")
          description.span.must_equal span
        end
      end

      describe "#html_attributes" do
        it "returns an empty hash by default" do
          description.html_attributes.must_equal({})
        end

        it "adds the css classes given by the :class option" do
          options[:class] = %w(bar baz)
          description.html_attributes.must_equal(:class => 'bar baz')
        end

        it "adds the css styles given by the :style option" do
          options[:style] = 'font-face: bold'
          description.html_attributes.must_equal(:style => 'font-face: bold')
        end

        it "sets the colspan when span is :all" do
          span = stub("span")
          row.stubs(:colspan).with(span).returns("5")
          options[:span] = span
          description.html_attributes.must_equal(:colspan => '5')
        end
      end

      describe "#render_header" do
        it "returns the titleized name" do
          description.render_header.must_equal "Foo"
        end

        it "returns the :title option if given" do
          options[:title] = 'bar'
          description.render_header.must_equal "bar"
        end
      end

      describe "#render_cell" do
        let(:results) { stub("results") }

        describe "on a column with no block" do
          it "sends its name to the datum" do
            datum = stub("datum", 'foo' => results)
            description.render_cell(datum).must_equal results
          end
        end

        describe "on a column with a block" do
          it "calls its block with the datum" do
            datum = stub("datum")
            column = ColumnDescription.new(row, name) do |block_arg|
              results if block_arg == datum
            end
            column.render_cell(datum).must_equal results
          end
        end
      end
    end
  end
end
