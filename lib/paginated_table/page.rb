module PaginatedTable
  class Page

    SORT_DIRECTIONS = %w(asc desc)
    DEFAULT_PER_PAGE = 10

    attr_reader :number, :rows, :sort_column, :sort_direction

    def self.opposite_sort_direction(sort_direction)
      index = SORT_DIRECTIONS.index(sort_direction)
      SORT_DIRECTIONS[index - 1]
    end

    def initialize(attributes)
      @number = Integer(attributes[:number] || 1)
      raise ArgumentError unless @number > 0
      @rows = Integer(attributes[:rows] || DEFAULT_PER_PAGE)
      raise ArgumentError unless @rows > 0
      @sort_column = attributes[:sort_column] || 'id'
      @sort_direction = attributes[:sort_direction] || 'asc'
      raise ArgumentError unless SORT_DIRECTIONS.include?(@sort_direction)
    end

    def page_for_number(number)
      Page.new(
        :number => number,
        :rows => rows,
        :sort_column => sort_column,
        :sort_direction => sort_direction
      )
    end

    def page_for_sort_column(new_sort_column)
      if sort_column == new_sort_column
        new_sort_direction = self.class.opposite_sort_direction(sort_direction)
      else
        new_sort_direction = nil
      end
      Page.new(
        :number => 1,
        :rows => rows,
        :sort_column => new_sort_column,
        :sort_direction => new_sort_direction
      )
    end

  end

  class PageParams
    def self.create_page_from_params(params)
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
