require 'will_paginate/array'

class DataController < ApplicationController
  Datum = Struct.new(:id, :name)

  DATA = (1..100).map do |i|
    Datum.new(i, "Name #{i}")
  end

  def index
    paginated_table(:data => DATA)
  end
end
