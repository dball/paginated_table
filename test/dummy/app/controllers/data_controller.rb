require 'will_paginate/array'

class DataController < ApplicationController
  Datum = Struct.new(:id, :name)

  DATA = (1..100).map do |i|
    Datum.new(i, "Name #{i}")
  end

  DEFAULT_PARAMS = {
    :page => 1,
    :per_page => 10
  }.with_indifferent_access

  def index
    requested_pagination_params = params.slice(:page)
    pagination_params = DEFAULT_PARAMS.merge(requested_pagination_params)
    @data = DATA.paginate(pagination_params)
    render :layout => false if request.xhr?
  end
end
