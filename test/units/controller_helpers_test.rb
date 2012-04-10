module PaginatedTable
  describe ControllerHelpers do
    let(:params) { stub("params") }
    let(:request) { stub("request", :xhr? => false) }
    let(:controller) {
      controller = Object.new
      controller.extend(ControllerHelpers)
      controller.stubs(:params => params, :request => request)
      controller
    }

    describe "#paginated_table" do
      let(:collection) { stub("collection") }
      let(:tables) { { "collection_name" => collection } }
      let(:page) { stub("page") }
      let(:data_page) { stub("data_page") }

      before do
        PageParams.stubs(:create_page_from_params).with(params).returns(page)
        DataPager.stubs(:data_for_page).with(collection, page).returns(data_page)
      end

      it "sets an instance variable on the controller with the data page" do
        controller.paginated_table(tables)
        controller.instance_variable_get("@collection_name").must_equal data_page
      end

      it "renders the named partial without layout if request is xhr?" do
        request.stubs(:xhr? => true)
        controller.expects(:render).
          with(:partial => "collection_name", :layout => false)
        controller.paginated_table(tables)
      end

      it "does not render if request is not xhr?" do
        request.stubs(:xhr? => false)
        controller.expects(:render).never
        controller.paginated_table(tables)
      end
    end
  end
end
