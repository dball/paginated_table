module PaginatedTable
  module ViewHelpers
    def paginated_table(collection, options = {})
      content_tag('table', '')
    end
  end
end

ActionView::Base.send :include, PaginatedTable::ViewHelpers
