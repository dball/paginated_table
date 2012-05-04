# PaginatedTable

[![Build Status](https://secure.travis-ci.org/dball/paginated_table.png)](http://travis-ci.org/dball/paginated_table)

PaginatedTable is a Rails plugin that makes rendering paginated, sorted
HTML tables dead simple.

## Requirements

* rails 3.2 (3.1 may work)
* will_paginate 3.0
* jquery-rails 2.0

## Installation

Add `paginated_table` to your `Gemfile` and `bundle install`.

Add the `paginated_table` javascript to your application's javascript
requires after `jquery` and `jquery_ujs`:

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
        paginated_table('products', Product.all,
          :defaults => { :sort_column => 'name' }
        )
      end
    end

This will sort the collection using Arel's order method, paginate
the given collection using will_paginate, store the
page in an instance variable of the given name, e.g. `@products`,
and if the request is AJAX, renders a partial response.

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
          table.column :name, :sortable => false, :class => 'centered'
          table.column :price, :style => 'font-face: bold' do |price|
            format_currency(price)
          end
          table.column :qty, :title => 'Quantity'
        end %>

The `div.paginated_table` element on the page will be updated for successful
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
results of which overwrite the paginated_table div. The column names
corresponding to sortable columns are linked to sort the table
ascending, then descending, restarting at the first page of the
collection.

### Output

    <div class="paginated_table">
      <div class="header">
        <div class="info">
          ... will_paginate info ...
        </div>
        <div class="links">
          <div class="pagination">
            ... will_paginate links ...
          </div>
        </div>
      </div>
      <table class="paginated">
        <thead>
          <tr>
            <th class="sortable sorted_asc">...</th>
            <th class="sortable">...</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>...</td>
            <td>...</td>
          </tr>
        </tbody>
      </table>
      <div class="footer">
        <div class="info">
          ... will_paginate info ...
        </div>
        <div class="links">
          <div class="pagination">
            ... will_paginate links ...
          </div>
        </div>
      </div>
    </div>

### Global Configuration

In an initializer, e.g. `config/initializers/paginated_table.rb`:

    PaginatedTable.configure do |config|
      config.rows_per_page = 20
    end

## TODO

* AJAX links should be optional

* AJAX busy indicator

* AJAX error indicator

* Partial should infer ivar by template name?

* Explicitly enable the :rows option
  * It really belongs in the view helper, but it's simpler to implement
    in the controller helper

* Global configuration
  * AJAX links

* :per_page request param should be allowed to be ignored or restricted
  to a configurable maximum

* scope th header elements to column

* allow column cells to render as th elements
