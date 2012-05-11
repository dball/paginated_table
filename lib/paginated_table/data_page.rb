module PaginatedTable
  class DataPage
    attr_reader :page, :data

    def initialize(collection, page)
      @page = page
      @data = collection.order(order_clause).paginate(pagination_params)
    end

    private

    def order_clause
      "#{@page.sort_column} #{@page.sort_direction}"
    end

    def pagination_params
      { :page => @page.number, :per_page => @page.rows }
    end
  end
end
