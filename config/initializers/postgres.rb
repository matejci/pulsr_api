module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def active?
        @connection.query 'SELECT 1'
        true
      rescue PGError
        false
      end
    end
  end
end