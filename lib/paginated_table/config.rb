module PaginatedTable
  def self.configure(&block)
    @configuration = Configuration.new(&block)
  end

  def self.configuration
    @configuration
  end

  class Configuration
    attr_accessor :rows_per_page

    def initialize
      yield self
    end
  end

  def self.set_default_configuration
    configure do |config|
      config.rows_per_page = 10
    end
  end

  set_default_configuration
end
