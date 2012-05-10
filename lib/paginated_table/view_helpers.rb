module PaginatedTable
  module ViewHelpers
    def paginated_table(data_page, &block)
      table_description = TableDescription.new(block)
      link_renderer = LinkRenderer.new(data_page.page)
      table_renderer = TableRenderer.new(self, table_description, data_page, link_renderer)
      table_renderer.render
    end
  end
end

ActionView::Base.send :include, PaginatedTable::ViewHelpers
