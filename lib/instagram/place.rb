class Instagram::Place
  attr_accessor :index, :temp_table_name, :filename, :connection

  FILE_COLUMNS = {
    place_id: :namespace_id,
    factual_id: :factual_id
  }

  TEMPORARY_COLUMNS = {
    factual_id: "factual_id character varying",
    place_id: "place_id integer"
  }

  PLACES_TABLE = {
    place_id: "place.place_id",
    factual_id: "place.factual_id",
    venue_id: "venue_id"
  }

  HEADERS = FILE_COLUMNS.keys

  class << self
    def csv_headers
      HEADERS
    end

    def log content, print = true
      Rails.logger.info "[#{DateTime.now}] #{content}" if print
    end
  end

  def initialize index
    @index = index
    @temp_table_name = "instagram_import_#{index}"
    @filename = Instagram::Importer.csv_file_name(index)
  end

  def process
    start_time = Time.current
    ActiveRecord::Base.transaction do
      process_data
    end

    log "IMPORT ENDED for #{@temp_table_name} in #{Time.now - start_time}s."
  end

  def process_data
    open_connection
    destroy_temp_table
    create_temp_table
    create_insert_function
    copy_file
    create_places
    remove_insert_function
    destroy_temp_table
    close_connection
  end

  def open_connection
    @connection = ActiveRecord::Base.connection_pool.checkout
  end

  def close_connection
    ActiveRecord::Base.connection_pool.checkin(@connection)
  end

  def create_temp_table
    log "CREATE TEMP table #{@temp_table_name}"
    command = <<-eos
      CREATE TEMP TABLE #{@temp_table_name} (#{temporary_columns.join(',')});
    eos

    execute(command)
    log "Finished creating temp table #{@temp_table_name}"
  end

  def destroy_temp_table
    command = "DROP TABLE IF EXISTS #{@temp_table_name};"

    execute command
    log "DROP table #{@temp_table_name}"
  end

  def copy_file
    log "COPY start to table #{@temp_table_name}"
    command = "COPY #{@temp_table_name} FROM STDIN (DELIMITER ';', FORMAT csv, HEADER);"

    raw  = @connection.raw_connection
    result = raw.copy_data command do
      File.open(@filename, 'r').each do |line|
        raw.put_copy_data line
      end
    end

    count = execute("SELECT COUNT(*) FROM #{@temp_table_name};").first
    log "COUNT #{count['count']} records"
    log "COPY finish to table #{@temp_table_name}"
  end

  def create_places
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{import_function_name}() RETURNS integer AS $$
      DECLARE
        place #{@temp_table_name}%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM #{@temp_table_name} LOOP
          PERFORM #{insert_function_name}(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos

    execute(function)
    log "INSERT instagram places started from table #{@temp_table_name}"
    log execute("SELECT #{import_function_name}();").first
    log "INSERT instagram places ended from table #{@temp_table_name}"
  end

  def create_insert_function
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{insert_function_name}(place #{temp_table_name}) RETURNS void AS $$
      DECLARE
        row_id instagram_places.id%TYPE;
        venue_id venues.id%TYPE;
      BEGIN
        SELECT id INTO venue_id FROM venues WHERE venues.factual_id = place.factual_id;

        INSERT INTO instagram_places(#{sql_columns})
        SELECT #{sql_data}
        WHERE NOT EXISTS (SELECT 1 FROM instagram_places WHERE instagram_places.id = place.place_id)
        RETURNING id INTO row_id;
      END;
      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos

    execute(function)
    log "CREATE function #{insert_function_name}"
  end

  def remove_insert_function
    execute("DROP FUNCTION #{insert_function_name}(place #{temp_table_name});")
    log "DROP FUNCTION #{insert_function_name}"
  end

  def import_function_name
    "instagram_import_#{index}"
  end

  def insert_function_name
    "insert_instagram_place_#{index}"
  end

  def sql_columns
    PLACES_TABLE.keys.join(", \n")
  end

  def sql_data
    PLACES_TABLE.values.join(", \n")
  end

  def log content
    Instagram::Place.log content, false
  end

  def execute command
    @connection.execute(command)
  end

  def temporary_columns
    FILE_COLUMNS.keys.map { |column| TEMPORARY_COLUMNS[column] }
  end
end