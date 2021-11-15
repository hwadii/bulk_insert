require_relative 'base_adapter'

module BulkInsert
  module StatementAdapters
    class PostgreSQLAdapter < BaseAdapter
      def insert_ignore_statement
        ''
      end

      def on_conflict_statement(columns, ignore, update_duplicates, update_duplicates_where)
        if ignore
          ' ON CONFLICT DO NOTHING'
        elsif update_duplicates
          update_values = columns.map do |column|
            next if column.name == 'created_at'
            "#{column.name}=EXCLUDED.#{column.name}"
          end.compact.join(', ')
          where = " WHERE #{update_duplicates_where}" if update_duplicates_where
          " ON CONFLICT(#{update_duplicates.join(', ')}) #{where} DO UPDATE SET #{update_values}"
        else
          ''
        end
      end

      def primary_key_return_statement(primary_key)
        " RETURNING #{primary_key}"
      end
    end
  end
end
