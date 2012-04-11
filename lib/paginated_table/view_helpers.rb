module PaginatedTable
  module ViewHelpers
    def paginated_table(data_page, &block)
      table_description = TableDescription.new(block)
      page = PageParams.create_page_from_params(params)
      link_renderer = LinkRenderer.new(page)
      table_renderer = RendersTable.new(self, table_description, data_page, link_renderer)
      table_renderer.render
    end
  end

  class TableDescription
    attr_reader :columns

    def initialize(description_proc = nil)
      @columns = []
      description_proc.call(self) if description_proc
    end

    def column(*args, &block)
      @columns << Column.new(*args, &block)
    end

    class Column
      attr_reader :name

      def initialize(name, options = {}, &block)
        @name = name
        @block = block
        @options = options
      end

      def render_header
        @options.fetch(:title, @name.to_s.titleize)
      end

      def render_cell(datum)
        if @block
          @block.call(datum)
        else
          datum.send(@name)
        end
      end

      def sortable?
        @options.fetch(:sortable, true)
      end
    end
  end

  class RendersTable
    def initialize(view, description, data_page, link_renderer)
      @view = view
      @description = description
      @data_page = data_page
      @link_renderer = link_renderer
    end

    def render
      pagination_area = render_pagination_area
      content = pagination_area + render_table + pagination_area
      @view.content_tag('div', content, :class => 'paginated_table')
    end

    def render_pagination_area
      content = render_pagination_info + render_pagination_links
      @view.content_tag('div', content, :class => 'header')
    end

    def render_pagination_info
      content = @view.page_entries_info(@data_page.data)
      @view.content_tag('div', content, :class => 'info')
    end

    def render_pagination_links
      content = @view.will_paginate(@data_page.data, :renderer => @link_renderer)
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
      css = []
      if column.sortable?
        css << 'sortable'
      end
      if @data_page.page.sort_column == column.name.to_s
        css << "sorted_#{@data_page.page.sort_direction}"
      end
      attributes = {}
      attributes[:class] = css.join(' ') unless css.empty?
      @view.content_tag('th', render_table_header_column_content(column), attributes)
    end

    def render_table_header_column_content(column)
      text = column.render_header
      if column.sortable?
        @link_renderer.sort_link(text, column.name.to_s)
      else
        text
      end
    end

    def render_table_body
      content = @data_page.data.map { |datum|
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
      @template.url_for(PageParams.to_params(new_page))
    end

    def default_url_params
      PageParams.to_params(@paginated_table_page)
    end
  end
end

ActionView::Base.send :include, PaginatedTable::ViewHelpers
