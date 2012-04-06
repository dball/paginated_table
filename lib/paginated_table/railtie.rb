module PaginatedTable
  class Railtie < Rails::Railtie
    initializer "paginated_table" do |app|
      ActiveSupport.on_load(:action_view) do
        require 'paginated_table/view_helpers'
      end
      ActiveSupport.on_load :action_controller do
        require 'paginated_table/controller_helpers'
      end
    end
  end
end
