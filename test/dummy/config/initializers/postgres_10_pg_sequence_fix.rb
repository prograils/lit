# In PostgreSQL 10 each sequence does not know `increment_by` or `min_value`
# This fix is already in Rails master, this is just monkey patch "to make it
# work" in Rails 4.2
# More details here: https://github.com/rails/rails/pull/28864
# Original issue: https://github.com/rails/rails/issues/28780
module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module SchemaStatements
        # Resets the sequence of a table's primary key to the maximum value.
        def reset_pk_sequence!(table, pk = nil, sequence = nil) #:nodoc:
          unless pk && sequence
            default_pk, default_sequence = pk_and_sequence_for(table)

            pk ||= default_pk
            sequence ||= default_sequence
          end

          if @logger && pk && !sequence
            @logger.warn "#{table} has primary key #{pk} with no default sequence."
          end

          if pk && sequence
            quoted_sequence = quote_table_name(sequence)
            max_pk = select_value("select MAX(#{quote_column_name pk}) from #{quote_table_name(table)}")
            if max_pk.nil?
              if postgresql_version >= 100000
                minvalue = select_value("SELECT seqmin from pg_sequence where seqrelid = '#{quoted_sequence}'::regclass")
              else
                minvalue = select_value("SELECT min_value FROM #{quoted_sequence}")
              end
            end

            select_value(<<-end_sql, "SCHEMA")
              SELECT setval('#{quoted_sequence}', #{max_pk ? max_pk : minvalue}, #{max_pk ? true : false})
            end_sql
          end
        end
      end
    end
  end
end
