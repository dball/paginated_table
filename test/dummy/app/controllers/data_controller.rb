require 'will_paginate/array'

class DataController < ApplicationController

  def index
    range =
      case params['search']
      when 'secondhalf' then (51..100)
      else (1..100)
      end
    paginated_table('data', data(range), :defaults => { :sort_column => 'id' })
  end

  private

  class Datum < Struct.new(:id, :name)
    extend ActiveModel::Naming

    def to_key
      [object_id]
    end

    def self.name
      "Data"
    end
  end

  module OrderableData
    def order(arg)
      column, direction = arg.split
      sorted_data = case column
      when 'name' then sort_by { |datum| datum[1] }
      when 'id' then sort_by { |datum| datum[0] }
      else raise "Invalid column: #{column}"
      end
      case direction
      when 'asc' then sorted_data
      when 'desc' then sorted_data.reverse
      else raise "Invalid direction: #{direction}"
      end
    end
  end
    
  def data(ids)
    data = ids.map { |i| Datum.new(i, "Name #{i}") }
    data.shuffle!
    data.extend(OrderableData)
    data
  end
end
