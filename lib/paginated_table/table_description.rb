module PaginatedTable
  class TableDescription
    attr_reader :columns, :rows

    def initialize(description_proc = nil)
      @columns = []
      @rows = []
      description_proc.call(self) if description_proc
    end

    def row(options = {}, &block)
      @explicit_rows = true
      create_row(options, block)
    end

    def column(*args, &block)
      raise Invalid if @explicit_rows
      default_row.column(*args, &block)
    end

    private

    def default_row
      @default_row ||= create_row
    end

    def create_row(options = {}, block = nil)
      row = RowDescription.new(options, block)
      @rows << row
      row
    end

    class Invalid < StandardError
    end
  end
end
