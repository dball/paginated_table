module PaginatedTable
  class Railtie < Rails::Railtie
    initializer "paginated_table" do |app|
      ActiveSupport.on_load(:action_view) do
        require 'paginated_table/view_helpers'
        require 'paginated_table/table_description'
        require 'paginated_table/row_description'
        require 'paginated_table/column_description'
        require 'paginated_table/table_renderer'
        require 'paginated_table/link_renderer'
      end
      ActiveSupport.on_load :action_controller do
        require 'paginated_table/controller_helpers'
        require 'paginated_table/page_params'
      end
    end
  end
end
