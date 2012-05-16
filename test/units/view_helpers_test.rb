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
    let(:options) { stub("options") }
    let(:page) { stub("page") }
    let(:data_page) { stub("data_page", :page => page) }
    let(:description_block) { lambda {} }

    describe "#paginated_table" do
      it "renders a table" do
        table_description = stub("table_description")
        TableDescription.stubs("new").with(options, description_block).
          returns(table_description)
        link_renderer = stub("link_renderer")
        LinkRenderer.stubs("new").with(page).returns(link_renderer)
        table_renderer = stub("table_renderer")
        TableRenderer.stubs("new").
          with(view, table_description, data_page, link_renderer).
          returns(table_renderer)
        table_renderer.expects("render")
        view.paginated_table(data_page, options, &description_block)
      end
    end
  end
end
