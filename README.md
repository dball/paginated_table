# PaginatedTable

[![Build Status](https://secure.travis-ci.org/dball/paginated_table.png)](http://travis-ci.org/dball/paginated\_table)

PaginatedTable is a Rails plugin that makes rendering paginated, sorted
HTML tables dead simple.

## Requirements

* rails 3.2 (3.1 may work)
* will\_paginate 3.0
* jquery-rails

## Installation

Add `paginated\_table` to your `Gemfile` and `bundle install`.

Add the `paginated\_table` javascript to your application's javascript
requires after `jquery` and `jquery\_ujs`:

    //= require jquery
    //= require jquery_ujs
    //= require paginated_table

## Usage

PaginatedTable mixes helper methods into ActionController::Base and
ActionView::Base, conveniently named `paginated_table`.

### Controller

The `paginated_table` helper is an instance method you can call in an
action that paginates a table:

    class ProductsController < ApplicationController
      def index
        paginated_table :products => Product.all
      end
    end

This will paginate the given collection using will\_paginate, store the
page in an instance variable with the name of the hash key, here
`@products`, and if the request is AJAX, renders with no layout.

### View

The `paginated_table` helper is an instance method you can call in a
view that renders a paginated table:

    <%= paginated_table(@products) do |table|
          table.column :name
          table.column :price do |price|
            format_currency(price)
          end
        end %>

The table DSL provides a column method by which you describe the table.
The column calls correspond to columns in the rendered table. Columns
with no block send their name to the records to get their cell values, while
columns with blocks yield to them the records to get their cell values.

The table gets a header row with titleized column names, and a
wrapping header and footer with pagination info and links. The
pagination links are decorated to be AJAX requests by jquery-rails, the
results of which overwrite the pagination div.

## TODO

* Sortable columns

* The AJAX link support should be a configuration option.

* AJAX links require that the paginated\_table helper be the only thing
in the view. The solution from which I'm working uses partials with
specific names. I could re-implement that using the ivar name, but that
still requires the view to be manually partialized at that seam. It
would be pretty swank to register the table descriptions, so I could
load and render them inline for xhr requests.
