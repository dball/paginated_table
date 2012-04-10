# PaginatedTable

[![Build Status](https://secure.travis-ci.org/dball/paginated_table.png)](http://travis-ci.org/dball/paginated\_table)

PaginatedTable is a Rails plugin that makes rendering paginated, sorted
HTML tables dead simple.

## Requirements

* rails 3.2 (3.1 may work)
* will_paginate 3.0
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

This will sort the collection using Arel's order method, paginate
the given collection using will_paginate, store the
page in an instance variable with the name of the hash key, e.g.
`@products`, and if the request is AJAX, renders a partial response.

### View

The `paginated_table` helper is an instance method you can call in a
view that renders a paginated table. To work with the AJAX pagination,
the call must appear in a partial with the same name as the table's
instance variable, e.g. `products.html.erb`. Thus, we might have:

In `index.html.erb`:

    <h1>Products</h1>

    <%= render :partial => 'products' %>

and in `products.html.erb`:

    <%= paginated_table(@products) do |table|
          table.column :name, :sortable => false
          table.column :price do |price|
            format_currency(price)
          end
        end %>

The `div.pagination` element on the page will be updated for successful
AJAX responses.

The table DSL provides a column method by which you describe the table.
The column calls correspond to columns in the rendered table. Columns
with no block send their name to the records to get their cell values, while
columns with blocks yield to them the records to get their cell values.
Columns are sortable by default, but may be rendered unsortable with the
:sortable option set to false.

The table gets a header row with titleized column names, and a
wrapping header and footer with pagination info and links. The
pagination links are decorated to be AJAX requests by jquery-rails, the
results of which overwrite the pagination div. The column names
corresponding to sortable columns are linked to sort the table
ascending, then descending, restarting at the first page of the
collection.

## TODO

* AJAX links should be optional

* Alternate column titles

* AJAX busy indicator

* AJAX error indicator
