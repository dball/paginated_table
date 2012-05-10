module PaginatedTable
  class ColumnDescription
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

    def html_attributes
      html_attributes = {}
      if @options[:class]
        html_attributes[:class] = Array(@options[:class]).join(' ')
      end
      if @options[:style]
        html_attributes[:style] = @options[:style]
      end
      html_attributes
    end
  end
end
