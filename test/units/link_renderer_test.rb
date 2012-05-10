require 'test_helper'

module PaginatedTable
  describe LinkRenderer do
    let(:page) { Page.new(:number => 2, :rows => 5, :sort_column => 'to_s', :sort_direction => 'desc') }
    let(:data) { (1..10).to_a }
    let(:data_page) { data.paginate(:page => 2, :per_page => 5) }
    let(:view) { stub("view") }
    let(:renderer) do
      renderer = LinkRenderer.new(page)
      renderer.prepare(data, {}, view)
      renderer
    end
    let(:text) { stub("text") }
    let(:href) { stub("href") }
    let(:link) { stub("link") }

    describe "#sort_link" do
      it "calls link_to on the view with the sort url and the :remote option" do
        view.stubs("url_for").
          with(:sort_direction => 'asc', :per_page => '5', :page => '1', :sort_column => 'to_s').
          returns(href)
        view.stubs("link_to").with(text, href, :remote => true).returns(link)
        renderer.sort_link(text, 'to_s').must_equal link
      end
    end

    describe "#tag" do
      it "calls link_to on the view with the :remote option for :a tags" do
        html_safe_text = stub("html_safe_text")
        text = stub("text", :to_s => stub("string", :html_safe => html_safe_text))
        view.expects(:link_to).
          with(html_safe_text, href, { :class => 'highlight', :remote => true }).
          returns(link)
        renderer.tag(:a, text, :class => 'highlight', :href => href).must_equal link
      end

      it "delegates to its parent for all other tags" do
        view.expects(:link_to).never
        renderer.tag(:span, "foo")
      end
    end
  end
end
