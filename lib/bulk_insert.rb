require 'bulk_insert/worker'

module BulkInsert
  extend ActiveSupport::Concern

  module ClassMethods
    def bulk_insert(*columns, values: nil, set_size:500, ignore: false, update_duplicates: false, update_duplicates_where: false, return_primary_keys: false)
      columns = default_bulk_columns if columns.empty?
      worker = BulkInsert::Worker.new(connection, table_name, primary_key, columns, set_size, ignore, update_duplicates, update_duplicates_where, return_primary_keys)

      if !values.nil?
        transaction do
          worker.add_all(values)
          worker.save!
        end
        return_primary_keys ? worker.inserted_ids : nil
      elsif block_given?
        transaction do
          yield worker
          worker.save!
        end
        return_primary_keys ? worker.inserted_ids : nil
      else
        worker
      end
    end

    # helper method for preparing the columns before a call to :bulk_insert
    def default_bulk_columns
      self.column_names - %w(id)
    end

  end
end

ActiveSupport.on_load(:active_record) do
  send(:include, BulkInsert)
end
