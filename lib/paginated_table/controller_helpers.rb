module PaginatedTable
  module ControllerHelpers
    def paginated_table(tables)
      ControllerHelper.new(self, tables).handle_request
    end
  end

  class ControllerHelper
    DEFAULT_PARAMS = {
      :page => 1,
      :per_page => 10
    }.with_indifferent_access

    def initialize(controller, tables)
      raise if tables.length > 1
      @controller = controller
      @name, @collection = tables.first
    end

    def request_params
      @controller.params.slice(:page)
    end

    def pagination_params
      DEFAULT_PARAMS.merge(request_params)
    end

    def page
      @collection.paginate(pagination_params)
    end

    def xhr_request?
      @controller.request.xhr?
    end

    def handle_request
      @controller.instance_variable_set(:"@#{@name}", page)
      @controller.render :layout => false if xhr_request?
    end
  end
end

ActionController::Base.send :include, PaginatedTable::ControllerHelpers
