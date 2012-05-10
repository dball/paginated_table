module PaginatedTable
  module ControllerHelpers
    def paginated_table(name, collection, options = {})
      defaults = options.fetch(:defaults, {})
      page = PageParams.create_page(params, defaults)
      data_page = DataPage.new(collection, page)
      instance_variable_set(:"@#{name}", data_page)
      if request.xhr?
        partial = options.fetch(:partial, name)
        render :partial => partial, :layout => false
      end
    end
  end
end

ActionController::Base.send :include, PaginatedTable::ControllerHelpers
