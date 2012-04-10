module PaginatedTable
  module ControllerHelpers
    def paginated_table(tables)
      raise ArgumentError if tables.length > 1
      name, collection = tables.first
      page = PageParams.create_page_from_params(params)
      data_page = DataPager.data_for_page(collection, page)
      instance_variable_set(:"@#{name}", data_page)
      render :partial => name.to_s, :layout => false if request.xhr?
    end
  end
end

ActionController::Base.send :include, PaginatedTable::ControllerHelpers
