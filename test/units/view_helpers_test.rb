require 'test_helper'

module PaginatedTable
  describe ViewHelpers do
    let(:params) { stub("params") }
    let(:view) {
      view = Object.new
      view.send(:extend, ViewHelpers)
      view.stubs("params" => params)
      view
    }
    let(:page) { stub("page") }
    let(:data_page) { stub("data_page", :page => page) }
    let(:description_block) { lambda {} }

    describe "#paginated_table" do
      it "renders a table" do
        table_description = stub("table_description")
        TableDescription.stubs("new").with(description_block).returns(table_description)
        link_renderer = stub("link_renderer")
        LinkRenderer.stubs("new").with(page).returns(link_renderer)
        table_renderer = stub("table_renderer")
        RendersTable.stubs("new").
          with(view, table_description, data_page, link_renderer).
          returns(table_renderer)
        table_renderer.expects("render")
        view.paginated_table(data_page, &description_block)
      end
    end
  end

  describe TableDescription do
    let(:description) { TableDescription.new }

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
        description.column(:foo)
        description.columns.must_equal [column]
      end
    end

    describe "#row" do
      it "constructs a new RowDescription and appends it to the rows array" do
        row = stub("row")
        options = stub("options")
        TableDescription::RowDescription.stubs(:new).with(options).returns(row)
        description.row(options)
        description.rows.must_equal [row]
      end
    end

  end

  describe TableDescription::Column do
    describe "#initialize" do
      it "creates a new instance with a name and an optional block" do
        TableDescription::Column.new(:foo) { true }
      end

      it "accepts an options hash" do
        TableDescription::Column.new(:foo, :baz => 'bat')
      end
    end

    describe "#sortable?" do
      it "returns true by default" do
        TableDescription::Column.new(:foo).sortable?.must_equal true
      end

      it "returns false if the :sortable option is false" do
        TableDescription::Column.new(:foo, :sortable => false).sortable?.must_equal false
      end
    end

    describe "#html_attributes" do
      it "returns an empty hash by default" do
        TableDescription::Column.new(:foo).html_attributes.must_equal({})
      end

      it "adds the css classes given by the :class option" do
        TableDescription::Column.new(:foo, :class => %w(bar baz)).
          html_attributes.must_equal({ :class => 'bar baz' })
      end

      it "adds the css styles given by the :style option" do
        TableDescription::Column.new(:foo, :style => 'font-face: bold').
          html_attributes.must_equal({ :style => 'font-face: bold' })
      end
    end

    describe "#render_header" do
      it "returns the titleized name" do
        TableDescription::Column.new(:foo).render_header.must_equal "Foo"
      end

      it "returns the :title option if given" do
        TableDescription::Column.new(:foo, :title => 'bar').
          render_header.must_equal "bar"
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

  describe TableDescription::RowDescription do
    let(:options) { {} }
    let(:description) { TableDescription::RowDescription.new(options) }

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
  end

  describe LinkRenderer do
    let(:page) { Page.new(:number => 2, :rows => 5, :sort_column => 'to_s', :sort_direction => 'desc') }
    let(:data) { (1..10).to_a }
    let(:data_page) { data.paginate(:page => 2, :per_page => 5) }
    let(:view) { stub("view") }
    let(:renderer) do
      renderer = LinkRenderer.new(page)
      renderer.prepare(data, {}, view)
      renderer
    end
    let(:text) { stub("text") }
    let(:href) { stub("href") }
    let(:link) { stub("link") }


    describe "#sort_link" do
      it "calls link_to on the view with the sort url and the :remote option" do
        view.stubs("url_for").
          with(:sort_direction => 'asc', :per_page => '5', :page => '1', :sort_column => 'to_s').
          returns(href)
        view.stubs("link_to").with(text, href, :remote => true).returns(link)
        renderer.sort_link(text, 'to_s').must_equal link
      end
    end

    describe "#tag" do
      it "calls link_to on the view with the :remote option for :a tags" do
        html_safe_text = stub("html_safe_text")
        text = stub("text", :to_s => stub("string", :html_safe => html_safe_text))
        view.expects(:link_to).
          with(html_safe_text, href, { :class => 'highlight', :remote => true }).
          returns(link)
        renderer.tag(:a, text, :class => 'highlight', :href => href).must_equal link
      end

      it "delegates to its parent for all other tags" do
        view.expects(:link_to).never
        renderer.tag(:span, "foo")
      end
    end

  end

  describe RendersTable do
    let(:view) { stub("view") }
    let(:description) { stub("description") }
    let(:data) { stub("data") }
    let(:page) { stub("page", :sort_column => 'title', :sort_direction => 'asc') }
    let(:data_page) { stub("data_page", :data => data, :page => page) }
    let(:link_renderer) { stub("link_renderer") }
    let(:table) { RendersTable.new(view, description, data_page, link_renderer) }

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
        table = RendersTable.new(view, description, data_page, link_renderer)
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
        css = stub("css")
        view.stubs(:cycle).with('odd', 'even').returns(css)
        view.expects(:content_tag).with('tr', "<cell1/><cell2/>", :class => css)
        table.render_table_body_row(datum)
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
