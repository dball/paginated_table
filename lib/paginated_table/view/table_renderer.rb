module PaginatedTable
  module View
    class TableRenderer
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
        options = { :model => @description.model_label }
        content = @view.page_entries_info(@data_page.data, options)
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
        @view.content_tag('thead', render_table_header_rows)
      end

      def render_table_header_rows
        @description.rows.select { |row|
          row.title == :header
        }.map { |row|
          render_table_header_row(row)
        }.reduce(&:+)
      end

      def render_table_header_row(row)
        content = row.columns.map { |column|
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
          render_table_body_rows(datum)
        }.reduce(&:+)
        @view.content_tag('tbody', content)
      end

      def render_table_body_rows(datum)
        @description.rows.map { |row|
          render_table_body_row(row, datum)
        }.reduce(&:+)
      end

      def render_table_body_row(row, datum)
        content = row.columns.map { |column|
          render_table_body_cell(datum, column)
        }.reduce(&:+)
        options = {}
        if row.cycle
          options[:class] = @view.cycle(*row.cycle)
        end
        if row.hidden
          options[:style] = 'display: none'
        end
        if row.data_type
          options[:"data-type"] = row.data_type
        end
        dom_id = @view.dom_id(datum)
        options[:"data-datum-id"] = dom_id
        @view.content_tag('tr', content, options)
      end

      def render_table_body_cell(datum, column)
        @view.content_tag('td', column.render_cell(datum), column.html_attributes)
      end
    end
  end
end
