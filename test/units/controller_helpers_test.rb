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
      let(:name) { "collection_name" }
      let(:collection) { stub("collection") }
      let(:page) { stub("page") }
      let(:data) { stub("data") }
      let(:data_page) { stub("data_page", :data => data, :page => page) }

      before do
        PageParams.stubs(:create_page).with(params, {}).returns(page)
        DataPage.stubs(:new).with(collection, page).returns(data_page)
      end

      it "sets an instance variable on the controller with the data page" do
        controller.paginated_table(name, collection)
        controller.instance_variable_get("@#{name}").must_equal data_page
      end

      it "renders the named partial without layout if request is xhr?" do
        request.stubs(:xhr? => true)
        controller.expects(:render).with(:partial => name, :layout => false)
        controller.paginated_table(name, collection)
      end

      it "renders the given partial without layout if request is xhr?" do
        partial = stub("partial")
        request.stubs(:xhr? => true)
        controller.expects(:render).with(:partial => partial, :layout => false)
        controller.paginated_table(name, collection, :partial => partial)
      end

      it "does not render if request is not xhr?" do
        request.stubs(:xhr? => false)
        controller.expects(:render).never
        controller.paginated_table(name, collection)
      end
    end
  end
end
