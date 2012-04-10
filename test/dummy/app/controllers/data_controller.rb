require 'will_paginate/array'

class DataController < ApplicationController
  Datum = Struct.new(:id, :name)

  DATA = (1..100).map do |i|
    Datum.new(i, "Name #{i}")
  end

  def DATA.order(arg)
    column, direction = arg.split
    sorted_data = case column
    when 'name' then DATA.sort_by { |datum| datum[1] }
    when 'id' then DATA
    else raise "Invalid column: #{column}"
    end
    case direction
    when 'asc' then sorted_data
    when 'desc' then sorted_data.reverse
    else raise "Invalid direction: #{direction}"
    end
  end

  def index
    paginated_table(:data => DATA)
  end
end
