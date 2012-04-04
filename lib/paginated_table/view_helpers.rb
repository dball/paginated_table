module PaginatedTable
  module ViewHelpers
    def paginated_table(collection, options = {})
      describer_class = options.fetch(:describer, TableDescription)
      renderer_class = options.fetch(:renderer, RendersTable)
      description = describer_class.new
      yield description
      renderer = renderer_class.new(self, description, collection)
      renderer.render
    end
  end

  class TableDescription
    attr_reader :columns

    def initialize
      @columns = []
    end

    def column(name, &block)
      @columns << Column.new(name, &block)
    end

    class Column
      def initialize(name, &block)
        @name = name
        @block = block
      end

      def render_cell(datum)
        if @block
          @block.call(datum)
        else
          datum.send(@name)
        end
      end
    end
  end

  class RendersTable
    def initialize(view, description, collection)
      @view = view
      @description = description
      @collection = collection
    end

    def render
      render_table
    end

    def render_table
      @view.content_tag('table', :class => 'paginated') do
        @view.content_tag('tbody') do
          render_rows
        end
      end
    end

    def render_rows
      @view.safe_join(@collection.map { |datum|
        @view.content_tag('tr', '') do
          render_cells(datum)
        end
      })
    end

    def render_cells(datum)
      @view.safe_join(@description.columns.map { |column|
        @view.content_tag('td', render_cell_content(column, datum))
      })
    end

    def render_cell_content(column, datum)
      column.render_cell(datum)
    end
  end
end

ActionView::Base.send :include, PaginatedTable::ViewHelpers
