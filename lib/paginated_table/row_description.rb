module PaginatedTable
  class RowDescription
    attr_reader :columns

    def initialize(table, options, description_proc)
      @table = table
      @options = options
      @columns = []
      description_proc.call(self) if description_proc
    end

    def title
      @options.fetch(:title, :header)
    end

    def cycle
      @options.fetch(:cycle, %w(odd even))
    end

    def hidden
      @options.fetch(:hidden, false)
    end

    def column(*args, &block)
      @columns << ColumnDescription.new(self, *args, &block)
    end

    def colspan(span)
      @table.colspan(span)
    end
  end
end
