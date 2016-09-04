class Factual::Venue
  attr_accessor :temp_table_name, :filename, :index, :diff_import, :connection

  FILE_COLUMNS = {
    factual_id: :factual_id,
    factual_existence: :existence,
    name: :name,
    street_address: [:address, :address_extended],
    city: :locality,
    zip_code: :postcode,
    country: :country, # us
    telephone_number: :tel,
    latitude: :latitude,
    longitude: :longitude,
    url: :website,
    email: :email,
    hours: :hours,
    category_ids: :category_ids,
    cuisine: :cuisine,
    price: :price,
    rating: :rating,
    created_at: :created_at,
    updated_at: :updated_at,
    short_factual_id: :short_factual_id
  }

  DIFF_FILE_COLUMNS = {
    delta: :delta,
    factual_id: :original_factual_id,
    new_factual_id: :current_factual_id,
    factual_existence: :existence,
    name: :name,
    street_address: [:address, :address_extended],
    city: :locality,
    zip_code: :postcode,
    country: :country, # us
    telephone_number: :tel,
    latitude: :latitude,
    longitude: :longitude,
    url: :website,
    email: :email,
    hours: :hours,
    category_ids: :category_ids,
    cuisine: :cuisine,
    price: :price,
    rating: :rating,
    created_at: :created_at,
    updated_at: :updated_at,
    short_factual_id: :short_factual_id
  }

  TEMPORARY_COLUMNS = {
    delta: "delta character varying",
    factual_id: "factual_id character varying",
    new_factual_id: "new_factual_id character varying",
    name: "name character varying",
    street_address: "street_address character varying",
    city: "city character varying",
    zip_code: "zip_code character varying",
    country: "country character varying",
    telephone_number: "telephone_number character varying",
    url: "url character varying",
    email: "email character varying",
    created_at: "created_at timestamp without time zone NOT NULL",
    updated_at: "updated_at timestamp without time zone NOT NULL",
    short_factual_id: "short_factual_id character varying",


    hours: "hours character varying",
    category_ids: "category_ids character varying",
    cuisine: "cuisine character varying",
    factual_existence: "factual_existence character varying",
    price: "price character varying",
    rating: "rating character varying",
    latitude: "latitude character varying",
    longitude: "longitude character varying"
    # hours: "hours jsonb",
    # category_ids: "category_ids json",
    # cuisine: "cuisine json",
    # factual_existence: "factual_existence real",
    # price: "price real",
    # rating: "rating real",
    # latitude: "latitude numeric(10,6)",
    # longitude: "longitude numeric(10,6)",
  }

  VENUE_TABLE = {
    factual_id: "venue.factual_id",
    factual_existence: "NULLIF(venue.factual_existence, 'REMOVE')::REAL",
    name: "venue.name",
    street_address: "venue.street_address",
    city: "venue.city",
    zip_code: "venue.zip_code",
    country: "venue.country",
    telephone_number: "venue.telephone_number",
    latitude: "NULLIF(venue.latitude, 'REMOVE')::NUMERIC(10,6)",
    longitude: "NULLIF(venue.longitude, 'REMOVE')::NUMERIC(10,6)",
    lonlat: "ST_SetSRID(ST_MakePoint(NULLIF(venue.longitude, 'REMOVE')::NUMERIC(10,6), NULLIF(venue.latitude, 'REMOVE')::NUMERIC(10,6)), 4326)::geography",
    url: "venue.url",
    email: "venue.email",
    hours: "NULLIF(venue.hours, 'REMOVE')::JSONB",
    cuisine: "NULLIF(venue.cuisine, 'REMOVE')::JSON",
    factual_price: "NULLIF(venue.price, 'REMOVE')::REAL",
    factual_rating: "NULLIF(venue.rating, 'REMOVE')::REAL",
    created_at: "current_date",
    updated_at: "current_date",
    short_factual_id: "venue.short_factual_id",
    created_by: "'#{::Venue::CREATED_BY_FACTUAL}'"
  }

  HEADERS = FILE_COLUMNS.keys
  DIFF_HEADERS = DIFF_FILE_COLUMNS.keys

  class << self
    def csv_headers
      HEADERS
    end

    def csv_diff_headers
      DIFF_HEADERS
    end

    def process_batches top_index = 1, diff_import = false
      start_time = Time.current
      1.upto(top_index) do |index|
          Factual::Venue.new(index, diff_import).process
          log "IMPORT ENDED for #{index} in #{Time.now - start_time}s."
      end
      log "IMPORT ALL ENDED in #{Time.now - start_time}s."
    end

    def log content, print = true
      Rails.logger.info "[#{DateTime.now}] #{content}" if print
    end
  end

  def initialize index, diff_import = false
    @diff_import = diff_import
    @index = index
    prepare_import
  end

  def prepare_import
    if diff_import
      @temp_table_name = "venues_diff_#{index}"
      @filename = Factual::DiffImporter.csv_file_name(index)
    else
      @temp_table_name = "venues_#{index}"
      @filename = Factual::Importer.csv_file_name(index)
    end
  end

  def process_diff
    @diff_import = true
    process
  end

  def process
    start_time = Time.current
    ActiveRecord::Base.transaction do
      if diff_import
        process_diff_data
      else
        process_data
      end
    end

    log "IMPORT ENDED for #{@temp_table_name} in #{Time.now - start_time}s."
  end

  def process_data
    open_connection
    destroy_temp_table
    create_temp_table
    create_processing_functions
    copy_file
    create_venues
    clean_up_processing_functions
    destroy_temp_table
    close_connection
  end

  def process_diff_data
    open_connection
    destroy_temp_table
    create_temp_diff_table
    create_processing_functions
    copy_file
    update_venues
    clean_up_processing_functions
    destroy_temp_table
    close_connection
  end

  def open_connection
    @connection = ActiveRecord::Base.connection_pool.checkout
  end

  def close_connection
    ActiveRecord::Base.connection_pool.checkin(@connection)
  end

  def create_temp_diff_table
    log "CREATE TEMP table #{@temp_table_name}"
    command = <<-eos
      CREATE TEMP TABLE #{@temp_table_name} (#{diff_temporary_columns.join(',')});
    eos

    execute(command)
    log "Finished creating temp table #{@temp_table_name}"
  end

  def create_temp_table
    log "CREATE TEMP TABLE #{@temp_table_name}"
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

  def create_venues
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{import_function_name}() RETURNS integer AS $$
      DECLARE
        venue #{@temp_table_name}%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR venue IN SELECT * FROM #{@temp_table_name} LOOP
          PERFORM #{insert_function_name}(venue);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos

    execute(function)
    log "INSERT venues started from table #{@temp_table_name}"
    log execute("SELECT #{import_function_name}();").first
    log "INSERT venues ended from table #{@temp_table_name}"
  end

  def update_venues
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{update_function_name}() RETURNS integer AS $$
      DECLARE
        venue #{@temp_table_name}%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR venue IN SELECT * FROM #{@temp_table_name} LOOP
          CASE venue.delta
          WHEN 'INSERT' THEN
            PERFORM #{insert_function_name}(venue);
          WHEN 'UPDATE' THEN
            PERFORM #{update_function_name}(venue);
          WHEN 'DEPRECATE' THEN
            PERFORM #{merge_function_name}(venue);
          WHEN 'DELETE' THEN
            PERFORM #{delete_function_name}(venue);
          END CASE;
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos

    execute(function)
    log "INSERT venues started from table #{@temp_table_name}"
    log execute("SELECT #{update_function_name}();").first
    log "INSERT venues ended from table #{@temp_table_name}"
  end

  def create_insert_function
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{insert_function_name}(venue #{temp_table_name}) RETURNS void AS $$
      DECLARE
        row_id venues.id%TYPE;
        category_id categories.id%TYPE;
      BEGIN
        INSERT INTO venues(#{sql_columns}) VALUES (#{sql_data}) RETURNING id INTO row_id;

        IF venue.category_ids IS NOT NULL THEN
          FOR category_id IN SELECT * FROM json_array_elements(NULLIF(venue.category_ids, 'REMOVE')::JSON)
          LOOP
            INSERT INTO categories_venues (category_id, venue_id, created_at, updated_at)
            VALUES (category_id, row_id, current_date, current_date);
          END LOOP;
        END IF;
      END;
      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos
    execute(function)
    log "CREATE function #{insert_function_name}"
  end

  def create_delete_function
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{delete_function_name}(venue #{temp_table_name}) RETURNS void AS $$
      DECLARE
        t_row venues%ROWTYPE;
      BEGIN
        SELECT * INTO t_row FROM venues WHERE venues.factual_id = venue.factual_id;

        IF t_row.eventful_id IS NOT NULL THEN
          UPDATE venues SET pending_at = current_date WHERE venues.factual_id = venue.factual_id;
        ELSE
          DELETE FROM venues
          WHERE ctid IN (
              SELECT ctid
              FROM venues
              WHERE venues.factual_id = venue.factual_id
              LIMIT 1);
          DELETE FROM categories_venues WHERE venue_id = t_row.id;
        END IF;
      END;
      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos
    execute(function)
    log "CREATE function #{delete_function_name}"
  end

  def create_merge_function
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{merge_function_name}(venue #{temp_table_name}) RETURNS void AS $$
      DECLARE
        t_row venues%ROWTYPE;
        t_new_row venues%ROWTYPE;
      BEGIN
        SELECT * INTO t_row FROM venues WHERE venues.factual_id = venue.factual_id;

        IF t_row.eventful_id IS NOT NULL THEN
          UPDATE venues SET
            eventful_id = NULLIF(COALESCE(eventful_id, t_row.eventful_id), 'REMOVE'),
            eventful_url = NULLIF(COALESCE(eventful_url, t_row.eventful_url), 'REMOVE'),
            name = NULLIF(COALESCE(name, t_row.name), 'REMOVE'),
            description = NULLIF(COALESCE(description, t_row.description), 'REMOVE'),
            street_address = NULLIF(COALESCE(street_address, t_row.street_address), 'REMOVE'),
            hours = NULLIF(COALESCE(hours, t_row.hours), 'REMOVE'),
            city = NULLIF(COALESCE(city, t_row.city), 'REMOVE'),
            region = NULLIF(COALESCE(region, t_row.region), 'REMOVE'),
            zip_code = NULLIF(COALESCE(zip_code, t_row.zip_code), 'REMOVE'),
            country = NULLIF(COALESCE(country, t_row.country), 'REMOVE'),
            time_zone = NULLIF(COALESCE(time_zone, t_row.time_zone), 'REMOVE'),
            latitude = COALESCE(latitude, t_row.latitude),
            longitude = COALESCE(longitude, t_row.longitude),
            lonlat = ST_SetSRID(ST_MakePoint(COALESCE(longitude, t_row.longitude), COALESCE(latitude, t_row.latitude)), 4326)::geography,
            updated_at = current_date
          WHERE venues.factual_id = venue.new_factual_id;

          SELECT * INTO t_new_row FROM venues WHERE venues.factual_id = venue.new_factual_id;

          UPDATE categories_venues SET
            venue_id = t_new_row.id
          WHERE venue_id = t_row.id;

          UPDATE events SET
            venue_id = t_new_row.id
          WHERE venue_id = t_row.id;
        END IF;

        DELETE FROM venues
        WHERE ctid IN (
            SELECT ctid
            FROM venues
            WHERE venues.id = t_row.id
            LIMIT 1);

        DELETE FROM categories_venues WHERE venue_id = t_row.id;
      END;

      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos
    execute(function)
    log "CREATE function #{merge_function_name}"
  end

  def create_update_function
    function = <<-eos
      CREATE OR REPLACE FUNCTION #{update_function_name}(venue #{temp_table_name}) RETURNS void AS $$
      DECLARE
        row_id venues.id%TYPE;
        cat_id categories.id%TYPE;
      BEGIN
        UPDATE venues SET
          factual_existence = NULLIF(COALESCE(venue.factual_existence, factual_existence::TEXT), 'REMOVE')::REAL,
          name = NULLIF(COALESCE(venue.name, name), 'REMOVE'),
          street_address = NULLIF(COALESCE(venue.street_address, street_address), 'REMOVE'),
          city = NULLIF(COALESCE(venue.city, city), 'REMOVE'),
          zip_code = NULLIF(COALESCE(venue.zip_code, zip_code), 'REMOVE'),
          country = NULLIF(COALESCE(venue.country, country), 'REMOVE'),
          telephone_number = NULLIF(COALESCE(venue.telephone_number, telephone_number), 'REMOVE'),
          latitude = NULLIF(COALESCE(venue.latitude, latitude::TEXT), 'REMOVE')::NUMERIC(10,6),
          longitude = NULLIF(COALESCE(venue.longitude, longitude::TEXT), 'REMOVE')::NUMERIC(10,6),
          lonlat = ST_SetSRID(ST_MakePoint(NULLIF(COALESCE(venue.longitude, longitude::TEXT), 'REMOVE')::NUMERIC(10,6), NULLIF(COALESCE(venue.latitude, latitude::TEXT), 'REMOVE')::NUMERIC(10,6)), 4326)::geography,
          url = NULLIF(COALESCE(venue.url, url), 'REMOVE'),
          email = NULLIF(COALESCE(venue.email, email), 'REMOVE'),
          hours = NULLIF(COALESCE(venue.hours, hours::TEXT), 'REMOVE')::JSONB,
          cuisine = NULLIF(COALESCE(venue.cuisine, cuisine::TEXT), 'REMOVE')::JSON,
          factual_price = NULLIF(COALESCE(venue.price, factual_price::TEXT), 'REMOVE')::REAL,
          factual_rating = NULLIF(COALESCE(venue.rating, factual_rating::TEXT), 'REMOVE')::REAL,
          updated_at = current_date,
          short_factual_id = NULLIF(COALESCE(venue.short_factual_id, short_factual_id), 'REMOVE'),
          factual_id = COALESCE(venue.new_factual_id, venue.factual_id)
        WHERE venues.factual_id = venue.factual_id;

        IF venue.category_ids IS NOT NULL THEN
          SELECT id INTO row_id FROM venues WHERE venues.factual_id = COALESCE(venue.new_factual_id, venue.factual_id);

          DELETE FROM categories_venues
          WHERE
            categories_venues.venue_id = row_id AND
            categories_venues.category_id NOT IN
              (SELECT value::text::integer FROM json_array_elements(NULLIF(venue.category_ids, 'REMOVE')::JSON));

          FOR cat_id IN SELECT * FROM json_array_elements(NULLIF(venue.category_ids, 'REMOVE')::JSON)
          LOOP
            INSERT INTO categories_venues (category_id, venue_id, created_at, updated_at)
            SELECT cat_id, row_id, current_date, current_date
            WHERE NOT EXISTS (SELECT 1 FROM categories_venues WHERE categories_venues.venue_id = row_id AND categories_venues.category_id = cat_id);
          END LOOP;
        END IF;
      END;
      $$ LANGUAGE 'plpgsql' VOLATILE;
    eos
    execute(function)
    log "CREATE function #{update_function_name}"
  end

  def remove_update_function
    execute("DROP FUNCTION #{update_function_name}(venue #{temp_table_name});")
    log "DROP FUNCTION #{update_function_name}"
  end

  def remove_merge_function
    execute("DROP FUNCTION #{merge_function_name}(venue #{temp_table_name});")
    log "DROP FUNCTION #{merge_function_name}"
  end

  def remove_delete_function
    execute("DROP FUNCTION #{delete_function_name}(venue #{temp_table_name});")
    log "DROP FUNCTION #{delete_function_name}"
  end

  def remove_insert_function
    execute("DROP FUNCTION #{insert_function_name}(venue #{temp_table_name});")
    log "DROP FUNCTION #{insert_function_name}"
  end

  def remove_import_function
    execute("DROP FUNCTION #{import_function_name}();")
    log "DROP FUNCTION #{import_function_name}"
  end


  def create_processing_functions
    create_update_function
    create_merge_function
    create_delete_function
    create_insert_function
  end

  def clean_up_processing_functions
    remove_update_function
    remove_merge_function
    remove_delete_function
    remove_insert_function
    # remove_import_function
  end

  def log content
    Factual::Venue.log content, false
  end

  def execute command
    @connection.execute(command)
  end

  def function_prefix
    "diff_" if diff_import
  end

  def function_suffix
    "_#{index}"
  end

  def import_function_name
    "import_process_#{index}"
  end

  def update_function_name
    "update_process_#{index}"
  end

  def diff_import_function_name
    "diff_import_process_#{index}"
  end

  def insert_function_name
    "#{function_prefix}insert_factual_venue#{function_suffix}"
  end

  def delete_function_name
    "#{function_prefix}delete_factual_venue#{function_suffix}"
  end

  def merge_function_name
    "#{function_prefix}merge_factual_venue#{function_suffix}"
  end

  def update_function_name
    "#{function_prefix}update_factual_venue#{function_suffix}"
  end

  def sql_columns
    VENUE_TABLE.keys.join(", \n")
  end

  def sql_data
    VENUE_TABLE.values.join(", \n")
  end

  def diff_temporary_columns
    DIFF_FILE_COLUMNS.keys.map { |column| TEMPORARY_COLUMNS[column] }
  end

  def temporary_columns
    FILE_COLUMNS.keys.map { |column| TEMPORARY_COLUMNS[column] }
  end
end