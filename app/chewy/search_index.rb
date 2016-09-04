class SearchIndex < Chewy::Index
  define_type Venue.where.not(name: nil).includes(:tags, events: [:performers]) do
    field :id
    field :name
    field :description
    field :street_address
    field :location, type: 'geo_point', value: -> { latitude.present? && longitude.present? ? {lat: latitude, lon: longitude} : nil }
    field :tags, index: 'not_analyzed', value: ->{ tags.map(&:name) }

    field :events do
      field :name
      field :description
      field :street_address, value: -> (event, venue) { venue.street_address }
      field :location, type: 'geo_point', value: -> { latitude.present? && longitude.present? ? {lat: latitude, lon: longitude} : nil }
      field :tags, index: 'not_analyzed', value: ->{ tags.map(&:name) }

      field :performers do
        field :name
        field :short_bio
        field :long_bio
      end
    end
  end

  define_type Event.where.not(name: nil).includes(:tags, :venue, :performers) do
    field :id
    field :name
    field :description
    field :street_address, value: -> (event) { event.venue.try(&:street_address) }
    field :location, type: 'geo_point', value: -> { latitude.present? && longitude.present? ? {lat: latitude, lon: longitude} : nil }
    field :tags, index: 'not_analyzed', value: ->{ tags.map(&:name) }
    field :is_public, value: -> (event) { event.public? }

    field :performers do
      field :name
      field :short_bio
      field :long_bio
    end
  end

  class << self
    def autocomplete_search(scope, query, options = {})
      options.reverse_merge!({
        limit: 10
      })

      es_query = {
        match: {
          name: {
            query: query,
            type: 'phrase_prefix',
          }
        }
      }

      scope.query(es_query).limit(options[:limit]).map(&:name).sort
    end

    def full_search(scope, query, options = {})
      options.reverse_merge!({
        limit: 10
      })

      es_query = {
        match: {
          _all: {
            query: query,
            fuzziness: 1,
            minimum_should_match: "75%"
          }
        }
      }

      search_result = scope.query(es_query)

      if options[:user].present?
        user = options[:user]

        event_ids = Invitation.events.
                               active.
                               where(user: user).
                               pluck(:invitable_id) + user.event_ids

        search_result = search_result.filter({
           bool: {
              should: [
                {
                  or: [{
                    term: {
                      _type: 'venue'
                    }
                  }, {
                    and: [
                      {
                        term: {
                          _type: 'event',
                        }
                      },
                      {
                        term: {
                          is_public: true
                        }
                      }
                    ]
                  }, {
                    and: [{
                      term: {
                        _type: 'event',
                      }
                    }, {
                      term: {
                        is_public: false
                      }
                    }, {
                      ids: {
                        values: event_ids
                      }
                    }]
                }]
               }
             ]
           }
        })
      end

      search_result.load(
        event: { scope: Event.preload(:venue, :photos, :tags, :timetables) },
        venue: { scope: Venue.preload(:tags, :photos) }
      ).limit(options[:limit])
    end

    def full_text_search(scope, query, options = {})

      options.reverse_merge!({ limit: 10 })

      search_query = {
        multi_match: {
          query: query,
          fields: [ "name", "title", "description", "tags" ],
          fuzziness: 1,
          minimum_should_match: "75%",
          type: 'best_fields' #Finds documents which match any field, but uses the _score from the best field.
        }
      }

      search_result = scope.query(search_query)

      if options[:user].present?
        user = options[:user]
        event_ids = Invitation.events.active.where(user: user).pluck(:invitable_id) + user.event_ids

        search_result = search_result.filter({
          bool: {
            should: [
                      {
                          or: [{ term: { _type: 'venue' }},
                          { and: [ {  term: { _type: 'event', } }, {  term: { is_public: true } } ] },
                          { and: [ {  term: { _type: 'event', } }, {  term: { is_public: false } }, { ids: { values: event_ids } }] }]
                      }
                    ]
                  }
                })

      end

      search_result.load(
                         event: { scope: Event.preload(:venue, :photos, :tags, :timetables) },
                         venue: { scope: Venue.preload(:tags, :photos) }
      ).limit(options[:limit]).page(options[:page])

    end
  end

end
