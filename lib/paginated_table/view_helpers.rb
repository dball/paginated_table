module PaginatedTable
  module ViewHelpers
    def paginated_table(collection, options = {})
      content_tag('table', :class => 'paginated') do
        content_tag('tbody') do
          safe_join(collection.map { |datum|
            content_tag('tr', '') do
              content_tag('td', datum.name)
            end
          })
        end
      end
    end
  end
end

ActionView::Base.send :include, PaginatedTable::ViewHelpers
