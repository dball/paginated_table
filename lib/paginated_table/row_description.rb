module PaginatedTable
  class RowDescription
    attr_reader :title, :cycle, :hidden, :columns

    def initialize(options, description_proc)
      @title = options.fetch(:title, :header)
      @cycle = options.fetch(:cycle, %w(odd even))
      @hidden = options.fetch(:hidden, false)
      @columns = []
      description_proc.call(self) if description_proc
    end

    def column(*args, &block)
      @columns << ColumnDescription.new(*args, &block)
    end
  end
end
