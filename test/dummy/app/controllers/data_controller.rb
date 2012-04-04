require 'will_paginate/array'

class DataController < ApplicationController
  Datum = Struct.new(:id, :name)

  DATA = (1..100).map do |i|
    Datum.new(i, "Name #{i}")
  end

  DEFAULT_PARAMS = {
    :page => 1,
    :per_page => 10
  }

  def index
    requested_pagination_params = params.fetch(:paginated_table, {})
    pagination_params = DEFAULT_PARAMS.merge(requested_pagination_params)
    @data = DATA.paginate(pagination_params)
  end
end
