require 'paginated_table/view/table_description'
require 'paginated_table/view/row_description'
require 'paginated_table/view/column_description'
require 'paginated_table/view/link_renderer'
require 'paginated_table/view/table_renderer'

module PaginatedTable
  module ViewHelpers
    def paginated_table(data_page, options = {}, &block)
      table_description = View::TableDescription.new(options, block)
      link_renderer = View::LinkRenderer.new(data_page.page)
      table_renderer = View::TableRenderer.new(self, table_description, data_page, link_renderer)
      table_renderer.render
    end
  end
end

ActionView::Base.send :include, PaginatedTable::ViewHelpers
