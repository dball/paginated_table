require 'test_helper'

module PaginatedTable
  describe TableRenderer do
    let(:view) { stub("view") }
    let(:description) { stub("description") }
    let(:data) { stub("data") }
    let(:page) { stub("page", :sort_column => 'title', :sort_direction => 'asc') }
    let(:data_page) { stub("data_page", :data => data, :page => page) }
    let(:link_renderer) { stub("link_renderer") }
    let(:table) { TableRenderer.new(view, description, data_page, link_renderer) }

    describe "#initialize" do
      it "creates a new instance with the view, description, and data_page" do
        table
      end
    end

    describe "#render" do
      it "makes a div.paginated_table with the table and a pagination header and footer" do
        table.stubs(:render_pagination_area).returns("<pagination/>")
        table.stubs(:render_table).returns("<table/>")
        view.expects(:content_tag).with('div', "<pagination/><table/><pagination/>", :class => 'paginated_table')
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
        view.stubs(:page_entries_info).with(data).returns("<info/>")
        view.expects(:content_tag).with('div', "<info/>", :class => 'info')
        table.render_pagination_info
      end
    end

    describe "#render_pagination_links" do
      it "makes a div.links with the will_paginate links from will_paginate" do
        view.stubs(:will_paginate).
          with(data, :renderer => link_renderer).
          returns("<links/>")
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
      it "makes a thead with the table header rows" do
        table.stubs(:render_table_header_rows).returns("<header/>")
        view.expects(:content_tag).with('thead', "<header/>")
        table.render_table_header
      end
    end

    describe "#render_table_header_rows" do
      it "concatenates the table headers for the rows with :header titles" do
        rows = [
          stub("row", :title => :header),
          stub("row", :title => false),
          stub("row", :title => :header)
        ]
        description.stubs(:rows).returns(rows)
        table.stubs(:render_table_header_row).with(rows.first).returns("<row1/>")
        table.stubs(:render_table_header_row).with(rows.last).returns("<row2/>")
        table.render_table_header_rows.must_equal "<row1/><row2/>"
      end
    end

    describe "#render_table_header_row" do
      it "makes a tr with th columns" do
        columns = [stub("column1"), stub("column2")]
        row = stub("row", :columns => columns)
        table.stubs(:render_table_header_column).with(columns.first).returns("<col1/>")
        table.stubs(:render_table_header_column).with(columns.last).returns("<col2/>")
        view.expects(:content_tag).with('tr', "<col1/><col2/>")
        table.render_table_header_row(row)
      end
    end

    describe "#render_table_header_column" do
      it "makes a th with the render_header from the column" do
        column = stub("column", :name => 'foo', :sortable? => false)
        table.stubs(:render_table_header_column_content).with(column).returns("<header/>")
        view.expects(:content_tag).with('th', "<header/>", {})
        table.render_table_header_column(column)
      end

      describe "when the table is sorted on the column ascending" do
        it "makes a th with css class 'sortable sorted_asc'" do
          column = stub("column", :name => 'title', :sortable? => true)
          table.stubs(:render_table_header_column_content).with(column).returns("<header/>")
          view.expects(:content_tag).
            with('th', "<header/>", :class => 'sortable sorted_asc')
          table.render_table_header_column(column)
        end
      end

      describe "when the table is sorted on the column descending" do
        it "makes a th with css class 'sortable sorted_asc'" do
          column = stub("column", :name => 'title', :sortable? => true)
          page.stubs(:sort_direction => 'desc')
          table.stubs(:render_table_header_column_content).with(column).returns("<header/>")
          view.expects(:content_tag).
            with('th', "<header/>", :class => 'sortable sorted_desc')
          table.render_table_header_column(column)
        end
      end
    end

    describe "#render_table_header_column_content" do
      describe "with a sortable column" do
        let(:column) { stub("column", :name => :foo, :render_header => '<header/>', :sortable? => true) }

        it "asks the link renderer to render a link to sort the column" do
          result = stub("result")
          link_renderer.stubs(:sort_link).with("<header/>", 'foo').returns(result)
          table.render_table_header_column_content(column).must_equal result
        end
      end

      describe "with an unsortable column" do
        let(:column) { stub("column", :render_header => '<header/>', :sortable? => false) }

        it "simply renders the column's header" do
          table.render_table_header_column_content(column).must_equal '<header/>'
        end
      end
    end

    describe "#render_table_body" do
      it "makes a tbody with the table body rows" do
        data = [stub("datum1"), stub("datum2")]
        data_page = stub("data_page", :data => data)
        table = TableRenderer.new(view, description, data_page, link_renderer)
        table.stubs(:render_table_body_rows).with(data.first).returns("<row1/>")
        table.stubs(:render_table_body_rows).with(data.last).returns("<row2/>")
        view.expects(:content_tag).with('tbody', "<row1/><row2/>")
        table.render_table_body
      end
    end

    describe "#render_table_body_rows" do
      it "concatenates the interleaved table body rows for the rows" do
        datum = stub("datum")
        rows = [stub("row"), stub("row")]
        description.stubs(:rows).returns(rows)
        table.stubs(:render_table_body_row).with(rows.first, datum).returns("1")
        table.stubs(:render_table_body_row).with(rows.last, datum).returns("2")
        table.render_table_body_rows(datum).must_equal "12"
      end
    end

    describe "#render_table_body_row" do
      it "makes a tr with the table body cells" do
        datum = stub("datum")
        columns = [stub("column1"), stub("column2")]
        cycle = stub("cycle")
        row = stub("row", :columns => columns, :cycle => %w(foo bar))
        table.stubs(:render_table_body_cell).with(datum, columns.first).returns("<cell1/>")
        table.stubs(:render_table_body_cell).with(datum, columns.last).returns("<cell2/>")
        css = stub("css")
        view.stubs(:cycle).with('foo', 'bar').returns(css)
        view.expects(:content_tag).with('tr', "<cell1/><cell2/>", :class => css)
        table.render_table_body_row(row, datum)
      end
    end

    describe "#render_table_body_cell" do
      it "makes a td with the render_cell from the column" do
        datum = stub("datum")
        column = stub("column")
        column.stubs(:render_cell).with(datum).returns("<datum/>")
        attributes = stub("attributes")
        column.stubs(:html_attributes).with().returns(attributes)
        view.expects(:content_tag).with('td', "<datum/>", attributes)
        table.render_table_body_cell(datum, column)
      end
    end
  end
end
