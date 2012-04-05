require 'test_helper'

module PaginatedTable
  describe ViewHelpers do
    let(:view) {
      view = Object.new
      view.send(:extend, ViewHelpers)
      view
    }

    describe "#paginated_table" do
      it "constructs a ViewHelper and calls render on it" do
        collection = stub("collection")
        options = stub("options")
        helper = stub("helper")
        block = lambda {}
        ViewHelper.stubs(:new).with(view, collection, options, block).returns(helper)
        results = stub("results")
        helper.stubs(:render).returns(results)
        view.paginated_table(collection, options, &block).must_equal results
      end
    end
  end

  describe ViewHelper do
    let(:view) { stub("view") }
    let(:collection) { stub("collection") }
    let(:description_proc) { stub("description_proc", :call => nil) }

    describe "#render" do
      it "calls render on the table renderer" do
        results = stub("results")
        RendersTable.any_instance.stubs(:render).returns(results)
        helper = ViewHelper.new(view, collection, {}, description_proc)
        helper.render.must_equal results
      end
    end

    describe "#table_description" do
      it "creates a new description with the description proc" do
        helper = ViewHelper.new(view, collection, {}, description_proc)
        TableDescription.expects(:new).with(description_proc)
        helper.table_description
      end
    end

    describe "#table_renderer" do
      it "constructs a new table renderer with the view, description, and collection" do
        helper = ViewHelper.new(view, collection, {}, description_proc)
        description = stub("description")
        helper.stubs(:table_description).returns(description)
        RendersTable.expects(:new).with(view, description, collection)
        helper.table_renderer
      end
    end

    describe "#table_renderer_class" do
      it "defaults to RendersTable" do
        helper = ViewHelper.new(view, collection, {}, description_proc)
        helper.table_renderer_class.must_equal RendersTable
      end

      it "accepts a :table_renderer option" do
        table_renderer_class = stub("table_renderer_class")
        options = { :table_renderer => table_renderer_class }
        helper = ViewHelper.new(view, collection, options, description_proc)
        helper.table_renderer_class.must_equal table_renderer_class
      end
    end

    describe "#table_describer_class" do
      it "defaults to TableDescription" do
        helper = ViewHelper.new(view, collection, {}, description_proc)
        helper.table_describer_class.must_equal TableDescription
      end

      it "accepts a :describer option" do
        table_describer_class = stub("table_describer_class")
        options = { :describer => table_describer_class }
        helper = ViewHelper.new(view, collection, options, description_proc)
        helper.table_describer_class.must_equal table_describer_class
      end
    end
  end

  describe TableDescription do
    describe "#initialize" do
      it "creates a new instance with empty columns" do
        TableDescription.new.columns.must_equal []
      end

      it "calls the given block with itself" do
        fake_proc = stub("proc")
        fake_proc.expects(:call)
        TableDescription.new(fake_proc)
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

  describe RendersTable do
    let(:view) { stub("view") }
    let(:description) { stub("description") }
    let(:collection) { stub("collection") }
    let(:table) { RendersTable.new(view, description, collection) }

    describe "#initialize" do
      it "creates a new instance with the view, description, and collection" do
        RendersTable.new(view, description, collection)
      end
    end

    describe "#render" do
      it "makes a div.pagination with the table and a pagination header and footer" do
        table.stubs(:render_pagination_area).returns("<pagination/>")
        table.stubs(:render_table).returns("<table/>")
        view.expects(:content_tag).with('div', "<pagination/><table/><pagination/>", :class => 'pagination')
        table.render
      end
    end

    describe "#render_pagination_area" do
      it "makes a div.header with the pagination info and links" do
        table.stubs(:render_pagination_info).returns("<info/>")
        table.stubs(:render_pagination_links).returns("<links/>")
        view.expects(:content_tag).with('div', "<info/><links/>", :class => 'header')
        table.render_pagination_area
      end
    end

    describe "#render_pagination_info" do
      it "makes a div.info with the page_entries_info from will_paginate" do
        view.stubs(:page_entries_info).with(collection).returns("<info/>")
        view.expects(:content_tag).with('div', "<info/>", :class => 'info')
        table.render_pagination_info
      end
    end

    describe "#render_pagination_links" do
      it "makes a div.links with the will_paginate links from will_paginate" do
        view.stubs(:will_paginate).with(collection).returns("<links/>")
        view.expects(:content_tag).with('div', "<links/>", :class => 'links')
        table.render_pagination_links
      end
    end

    describe "#render_table" do
      it "makes a table.paginated with the table header and body" do
        table.stubs(:render_table_header).returns("<header/>")
        table.stubs(:render_table_body).returns("<body/>")
        view.expects(:content_tag).with('table', "<header/><body/>", :class => 'paginated')
        table.render_table
      end
    end

    describe "#render_table_header" do
      it "makes a thead with the table header row" do
        table.stubs(:render_table_header_row).returns("<header/>")
        view.expects(:content_tag).with('thead', "<header/>")
        table.render_table_header
      end
    end

    describe "#render_table_header_row" do
      it "makes a tr with the table header columns" do
        columns = [stub("column1"), stub("column2")]
        description.stubs(:columns).returns(columns)
        table.stubs(:render_table_header_column).with(columns.first).returns("<col1/>")
        table.stubs(:render_table_header_column).with(columns.last).returns("<col2/>")
        view.expects(:content_tag).with('tr', "<col1/><col2/>")
        table.render_table_header_row
      end
    end

    describe "#render_table_header_column" do
      it "makes a th with the render_header from the column" do
        column = stub("column", :render_header => '<header/>')
        view.expects(:content_tag).with('th', "<header/>")
        table.render_table_header_column(column)
      end
    end

    describe "#render_table_body" do
      it "makes a tbody with the table body rows" do
        data = [stub("datum1"), stub("datum2")]
        table = RendersTable.new(view, description, data)
        table.stubs(:render_table_body_row).with(data.first).returns("<row1/>")
        table.stubs(:render_table_body_row).with(data.last).returns("<row2/>")
        view.expects(:content_tag).with('tbody', "<row1/><row2/>")
        table.render_table_body
      end
    end

    describe "#render_table_body_row" do
      it "makes a tr with the table body cells" do
        datum = stub("datum")
        columns = [stub("column1"), stub("column2")]
        description.stubs(:columns).returns(columns)
        table.stubs(:render_table_body_cell).with(datum, columns.first).returns("<cell1/>")
        table.stubs(:render_table_body_cell).with(datum, columns.last).returns("<cell2/>")
        view.expects(:content_tag).with('tr', "<cell1/><cell2/>")
        table.render_table_body_row(datum)
      end
    end

    describe "#render_table_body_cell" do
      it "makes a td with the render_cell from the column" do
        datum = stub("datum")
        column = stub("column")
        column.stubs(:render_cell).with(datum).returns("<datum/>")
        view.expects(:content_tag).with('td', "<datum/>")
        table.render_table_body_cell(datum, column)
      end
    end
  end
end
