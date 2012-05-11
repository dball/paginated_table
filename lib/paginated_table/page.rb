module PaginatedTable
  class Page
    SORT_DIRECTIONS = %w(asc desc)

    attr_reader :number, :rows, :sort_column, :sort_direction

    def self.opposite_sort_direction(sort_direction)
      index = SORT_DIRECTIONS.index(sort_direction)
      SORT_DIRECTIONS[index - 1]
    end

    def initialize(attributes)
      @number = Integer(attributes[:number] || 1)
      raise ArgumentError unless @number > 0
      @rows = Integer(attributes[:rows] || PaginatedTable.configuration.rows_per_page)
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
end
