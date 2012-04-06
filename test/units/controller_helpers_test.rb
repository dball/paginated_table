module PaginatedTable
  describe ControllerHelpers do
    let(:controller) {
      controller = Object.new
      controller.extend(ControllerHelpers)
      controller
    }

    describe "#paginated_table" do
      it "creates a new ControllerHelper and calls handle_request on it" do
        tables = stub("tables")
        helper = mock("helper", :handle_request => true)
        ControllerHelper.expects(:new).with(controller, tables).returns(helper)
        controller.paginated_table(tables)
      end
    end
  end

  describe ControllerHelper do
    let(:controller) { stub("controller") }
    let(:collection) { stub("collection") }
    let(:collection_name) { stub("collection_name", :to_s => "products") }
    let(:tables) { { collection_name => collection } }
    let(:helper) { ControllerHelper.new(controller, tables) }

    describe "#initialize" do
      it "accepts a hash of tables with one entry" do
        helper
      end

      it "does not accept a hash of tables with more than one entry" do
        tables[:another] = stub("another_collection")
        proc { helper }.must_raise RuntimeError
      end
    end

    describe "#request_params" do
      it "slices the page from the controller params" do
        controller.stubs(:params).returns(:page => '5', :foo => 'bar')
        helper.request_params.must_equal(:page => '5')
      end
    end

    describe "#pagination_params" do
      it "merges the default and request_params" do
        controller.stubs(:params).returns(:page => '5', :foo => 'bar')
        helper.pagination_params.must_equal(
          { :page => '5', :per_page => 10 }.with_indifferent_access
        )
      end
    end

    describe "#page" do
      it "paginates the collection with the pagination_params" do
        controller.stubs(:params).returns(:page => '5', :foo => 'bar')
        page = stub("page")
        collection.expects(:paginate).
          with({ :page => '5', :per_page => 10 }.with_indifferent_access).
          returns(page)
        helper.page.must_equal page
      end
    end

    describe "#xhr_request?" do
      it "delegates to the controller request" do
        result = stub("result")
        request = stub("request", :xhr? => result)
        controller.stubs(:request => request)
        helper.xhr_request?.must_equal result
      end
    end

    describe "#handle_request" do
      let(:page) { stub("page") }

      before do
        helper.stubs(:page => page)
        helper.stubs(:xhr_request? => false)
      end

      it "sets a controller ivar to the page" do
        helper.handle_request
        controller.instance_variable_get("@products").must_equal page
      end

      it "does not render anything for page requests" do
        controller.expects(:render).never
        helper.handle_request
      end

      it "renders with no layout for xhr requests" do
        helper.stubs(:xhr_request? => true)
        controller.expects(:render).with(:layout => false)
        helper.handle_request
      end
    end
  end
end
