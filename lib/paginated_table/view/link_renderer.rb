module PaginatedTable
  module View
    class LinkRenderer < WillPaginate::ActionView::LinkRenderer
      def initialize(page)
        super()
        @paginated_table_page = page
      end

      def sort_link(text, sort_on)
        @template.link_to(text, sort_url(sort_on), :remote => true)
      end

      def tag(name, value, attributes = {})
        if name == :a
          @template.link_to(value.to_s.html_safe, attributes.delete(:href), attributes.merge(:remote => true))
        else
          super
        end
      end

      private

      def sort_url(sort_on)
        new_page = @paginated_table_page.page_for_sort_column(sort_on)
        new_page_params = PageParams.to_params(new_page)
        params = merge_get_params({})
        symbolized_update(params, new_page_params)
        @template.url_for(params)
      end

      def default_url_params
        PageParams.to_params(@paginated_table_page)
      end
    end
  end
end
