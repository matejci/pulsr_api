# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

cities = City.create([
  {
    id: 1,
    name: 'Austin',
    latitude: 30.2500,
    longitude: -97.7500,
    radius: 20000,
    timezone: 'US/Central',
    boundaries: {
      top: {
        left: {
          latitude: 30.58590,
          longitude: -97.96234
        },
        right: {
          latitude: 30.58590,
          longitude: -97.38830
        }
      },
      bottom: {
        left: {
          latitude: 30.13562,
          longitude: -97.96234
        },
        right: {
          latitude: 30.13562,
          longitude: -97.38830
        }
      }
    }
  },
  {
    id: 2,
    name: 'New York City',
    latitude: 40.6643,
    longitude: -73.9385,
    radius: 20000,
    timezone: 'US/Eastern',
    boundaries: {
      top: {
        left: {
          latitude: 40.95189,
          longitude: -74.06845
        },
        right: {
          latitude: 40.95189,
          longitude: -73.60290
        }
      },
      bottom: {
        left: {
          latitude: 40.53050,
          longitude: -74.06845
        },
        right: {
          latitude: 40.53050,
          longitude: -73.60290
        }
      }
    }
  },
  {
    id: 3,
    name: 'Los Angeles',
    latitude: 34.0194,
    longitude: -118.4108,
    radius: 20000,
    timezone: 'US/Pacific',
    boundaries: {
      top: {
        left: {
          latitude: 34.16636,
          longitude: -118.54797
        },
        right: {
          latitude: 34.16636,
          longitude: -117.57843
        }
      },
      bottom: {
        left: {
          latitude: 33.52078,
          longitude: -118.54797
        },
        right: {
          latitude: 33.52078,
          longitude: -117.57843
        }
      }
    }
  },
  {
    id: 4,
    name: 'Chicago',
    latitude: 41.8376,
    longitude: -87.6818,
    radius: 20000,
    timezone: 'US/Central',
    boundaries: {
      top: {
        left: {
          latitude: 42.212966,
          longitude: -88.147355
        },
        right: {
          latitude: 42.212966,
          longitude: -87.200601
        }
      },
      bottom: {
        left: {
          latitude: 41.519114,
          longitude: -88.147355
        },
        right: {
          latitude: 41.519114,
          longitude: -87.200601
        }
      }
    }
  },
  {
    id: 5,
    name: 'Houston',
    latitude: 29.7805,
    longitude: -95.3863,
    radius: 20000
  },
  {
    id: 6,
    name: 'Philadelphia',
    latitude: 40.0094,
    longitude: -75.1333,
    radius: 20000
  },
  {
    id: 7,
    name: 'Washington',
    latitude: 38.9041,
    longitude: -77.0171,
    radius: 20000
  },
  {
    id: 8,
    name: 'San Francisco',
    latitude: 37.7751,
    longitude: -122.4193,
    radius: 20000,
    timezone: 'US/Pacific',
    boundaries: {
      top: {
        left: {
          latitude: 37.83364,
          longitude: -122.60467
        },
        right: {
          latitude: 37.83364,
          longitude: -122.30529
        }
      },
      bottom: {
        left: {
          latitude: 37.48793,
          longitude: -122.60467
        },
        right: {
          latitude: 37.48793,
          longitude: -122.30529
        }
      }
    }
  },
  {
    id: 9,
    name: 'Boston',
    latitude: 42.3320,
    longitude: -71.0202,
    radius: 20000
  },
  {
    id: 10,
    name: 'Dallas',
    latitude: 32.7757,
    longitude: -96.7967,
    radius: 20000
  },
  {
    id: 11,
    name: 'Miami',
    latitude: 25.7752,
    longitude: -80.2086,
    radius: 20000
  },
  {
    id: 12,
    name: 'Atlanta',
    latitude: 33.7629,
    longitude: -84.4227,
    radius: 20000
  },
  {
    id: 13,
    name: 'Detroit',
    latitude: 42.3830,
    longitude: -83.1022,
    radius: 20000
  },
  {
    id: 14,
    name: 'Seattle',
    latitude: 47.6205,
    longitude: -122.3509,
    radius: 20000
  },
  {
    id: 15,
    name: 'Long Beach',
    latitude: 33.8091,
    longitude: -118.1553,
    radius: 20000
  },
  {
    id: 16,
    name: 'Phoenix',
    latitude: 33.5722,
    longitude: -112.0880,
    radius: 20000
  },
  {
    id: 17,
    name: 'Minneapolis',
    latitude: 44.9633,
    longitude: -93.2683,
    radius: 20000
  },
  {
    id: 18,
    name: 'Philadelphia',
    latitude: 40.0094,
    longitude: -75.1333,
    radius: 20000
  },
  {
    id: 19,
    name: 'Cleveland',
    latitude: 41.4781,
    longitude: -81.6795,
    radius: 20000
  },
  {
    id: 20,
    name: 'Denver',
    latitude: 39.7618,
    longitude: -104.8806,
    radius: 20000
  },
  {
    id: 21,
    name: 'San Diego',
    latitude: 32.8153,
    longitude: -117.1350,
    radius: 20000
  },
  {
    id: 22,
    name: 'Portland',
    latitude: 45.5370,
    longitude: -122.6500,
    radius: 20000
  }
])

PostType.create([
  {
    id: 1,
    name: 'User'
  },
  {
    id: 2,
    name: 'Facebook'
  },
  {
    id: 3,
    name: 'Twitter'
  },
  {
    id: 4,
    name: 'Instagram'
  },
  {
    id: 5,
    name: 'Flickr'
  },
  {
    id: 6,
    name: 'Eventful'
  }
])

TasteCategory.create([
  {
    id: 1,
    name: 'Event'
  },
  {
    id: 2,
    name: 'Non-food and drink location'
  },
  {
    id: 3,
    name: 'Food and Drink location'
  }
])

# Create categories from factual
`rake factual:import_categories`
`rake tastes:import`

