module PaginatedTable
  module ControllerHelpers
    def paginated_table(*args)
      options = args.extract_options!
      case args.length
      when 1
        collection = args.first
      when 2
        name = args.first
        collection = args.last
      else
        raise ArgumentError
      end
      defaults = options.fetch(:defaults, {})
      page = PageParams.create_page(params, defaults)
      data_page = DataPage.new(collection, page)
      if name
        instance_variable_set(:"@#{name}", data_page)
        if request.xhr?
          partial = options.fetch(:partial, name)
          render :partial => partial, :layout => false
        end
      end
      data_page
    end
  end
end

ActionController::Base.send :include, PaginatedTable::ControllerHelpers
