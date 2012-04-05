module PaginatedTable
  module ViewHelpers
    def paginated_table(collection, options = {}, &block)
      describer_class = options.fetch(:describer, TableDescription)
      renderer_class = options.fetch(:renderer, RendersTable)
      Handler.handle(self, describer_class, renderer_class, collection, &block)
    end
  end

  class Handler
    def self.handle(view, describer_class, renderer_class, collection)
      description = describer_class.new
      yield description
      renderer = renderer_class.new(view, description, collection)
      renderer.render
    end
  end

  class TableDescription
    attr_reader :columns

    def initialize
      @columns = []
    end

    def column(*args, &block)
      @columns << Column.new(*args, &block)
    end

    class Column
      def initialize(name, &block)
        @name = name
        @block = block
      end

      def render_header
        @name.to_s.titleize
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
        render_table_header + render_table_body
      end
    end

    def render_table_header
      @view.content_tag('thead') do
        @view.content_tag('tr') do
          @view.safe_join(@description.columns.map { |column|
            @view.content_tag('th', column.render_header)
          })
        end
      end
    end

    def render_table_body
      @view.content_tag('tbody') do
        render_rows
      end
    end

    def render_rows
      @view.safe_join(@collection.map { |datum|
        @view.content_tag('tr') do
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
