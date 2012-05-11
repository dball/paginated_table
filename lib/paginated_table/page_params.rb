module PaginatedTable
  class PageParams
    def self.create_page(request_params, defaults = {})
      params = request_params.reverse_merge(defaults)
      Page.new(
        :number => params[:page],
        :rows => params[:per_page],
        :sort_column => params[:sort_column],
        :sort_direction => params[:sort_direction]
      )
    end

    def self.to_params(page)
      {
        :page => page.number.to_s,
        :per_page => page.rows.to_s,
        :sort_column => page.sort_column,
        :sort_direction => page.sort_direction
      }
    end
  end
end
