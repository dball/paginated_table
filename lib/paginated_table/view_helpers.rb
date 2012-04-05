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
      pagination_area = render_pagination_area
      content = pagination_area + render_table + pagination_area
      @view.content_tag('div', content, :class => 'pagination')
    end

    def render_pagination_area
      content = render_pagination_info + render_pagination_links
      @view.content_tag('div', content, :class => 'header')
    end

    def render_pagination_info
      content = @view.page_entries_info(@collection)
      @view.content_tag('div', content, :class => 'info')
    end

    def render_pagination_links
      content = @view.will_paginate(@collection)
      @view.content_tag('div', content, :class => 'links')
    end

    def render_table
      content = render_table_header + render_table_body
      @view.content_tag('table', content, :class => 'paginated')
    end

    def render_table_header
      @view.content_tag('thead', render_table_header_row)
    end

    def render_table_header_row
      content = @description.columns.map { |column|
        render_table_header_column(column)
      }.reduce(&:+)
      @view.content_tag('tr', content)
    end

    def render_table_header_column(column)
      @view.content_tag('th', column.render_header)
    end

    def render_table_body
      content = @collection.map { |datum|
        render_table_body_row(datum)
      }.reduce(&:+)
      @view.content_tag('tbody', content)
    end

    def render_table_body_row(datum)
      content = @description.columns.map { |column|
        render_table_body_cell(datum, column)
      }.reduce(&:+)
      @view.content_tag('tr', content)
    end

    def render_table_body_cell(datum, column)
      @view.content_tag('td', column.render_cell(datum))
    end
  end
end

ActionView::Base.send :include, PaginatedTable::ViewHelpers
