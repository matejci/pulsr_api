# pulsr_backend_main

## Time zone handling

If you want to get the ranges specific to a time zone, like saved objects that you need to provide to get the correct range for that day you can use the additional parameter "current_time_zone". This parameters accepts any valid timezone name and it will use it by default for all actions within the request.

current_time_zone="America/Los_Angeles"

here is the list of timezones https://en.wikipedia.org/wiki/List_of_tz_database_time_zones that are supported. Use the TZ column for the timezone name as it will automatically resolve daylight savings changes based on the dates.

## Phone number change

For every phone number change you will need to confirm the number. A sms is going to be sent to that phone number which will be needed to confirm this phone number
before becoming active one for the user.
Besides the phone_number in user account details response you will receive also temp_phone_number that will show if the user is currently pending to confirm new phone number.

## Friend user details

Get basic details about a friend

curl -X "GET" "http://staging.pulsr.com/api/users/1.json" -H "Content-Type: application/json" -H "Access-Token: hmoA6i-PbvxFtw4gUu_r"

### Request to send updated phone number

curl -X "POST" "http://staging.pulsr.com/api/account.json" -H "Content-Type: application/json" -H "Access-Token: umQLshXMND5oDnS419jY" -d "{\"user\":{\"phone_number\":\"123456\"}}"

### Once the user receives the code through sms it is sent on the confirmation endpoint

curl -X "POST" "http://staging.pulsr.com/api/confirm_code.json" -H "Content-Type: application/json" -H "Access-Token: umQLshXMND5oDnS419jY" -d "{\"code\":\"123456\"}"

## Toggle tastes

You can manually update the specific taste instead of doing batch taste updates

Add new taste
curl -X "POST" "http://staging.pulsr.com/api/tastes.json" -H "Content-Type: application/json" -H "Access-Token: umQLshXMND5oDnS419jY" -d "{\"id\":\"123456\"}"

Remove taste
curl -X "DELETE" "http://staging.pulsr.com/api/tastes.json" -H "Content-Type: application/json" -H "Access-Token: umQLshXMND5oDnS419jY" -d "{\"id\":\"123456\"}"

Fields:
- id; taste id

## Response data fields

success: (false|true) describes if the action was successful or not
info: represents additional information about the performerd action
  - registered, new user has been created
  - logged_in, user has been logged in, data will provide access token
  - user_exists, when using facebook login if there is an existing user in the database that has the same email as the facebook account you are trying to log in.
message: detailed string representation of the results. Mostly used for error messages that should be shown to the user
data: response data for the requested action


## Post object

List of post types that are available
{
  user: 1,
  facebook: 2,
  twitter: 3,
  instagram: 4
}


# Pulsr Backend Data Processing

There are various features that are contained within this app:

#Stock Image uploading for Taste
Stock images can be uploaded to the taste. In case of event/location with no images, these stock images related to the event/venue through tags can be displayed.
To upload all the stock images u need to run the rake task:

rake tastes:import_photos

for successfully uploading files, it should be in a folder with following convention:

Rails.root/CategoryImages/#{taste category}/#{import_string}/*.jpeg

for e.g:

this should be the file convention for taste with taste category as event and import_string as Comedy

/home/siddhant/projects/sd2labs/pulsr_backend_main/CategoryImages/Event/Comedy/AdobeStock_26040549.jpeg

# Twitter Stream Receiver

It receives the Tweets through Twitter stream and publishes them into two pubsub channels. It receives only Tweets that are geotagged with the location of cities that have the boundaries.

Pubsub channels:
- event:twitter_channel: receives all the tweets that have exact geo coordinates
- event:twitter_stream_channel: receives all the tweets that are coming in

This is happening in realtime. It can be invoked with:

rake twitter:stream

It also has a upstart service configuration at config/upstart/twitterstream.conf

# Twitter Subscriber

Receives the tweet that belong to a specific city and sorts them into the grids for the bubble clustering in the activity map. It receives tweets from event:twitter_channel channel. It calculates them on 15 minutes period.

This is happening in realtime. It can be invoked with:

rake twitter:realtime_process

It also has a upstart service configuration at config/upstart/twitterstream.conf

# Twitter Subscriber cron job

Once per day it purges the tweet data that is older than 5 days. It can be run manually with:

rake twitter:prune_old_tweets

# Eventful process events

It processes events from the Eventful api. It looks up for the next 5 days of events and the related venues and performers.

It can be run manually with rake:

rake eventful:process_new_events

It is running as a daily cron job for parsing the events and it is using sidekiq workers to process all the work.

# Factual Importer

It imports the factual venues from the factual dump file directly into the venue database.

# UPSTART services

## Twitter stream
This is the live twitter stream running service

sudo service twitter [start|stop|restart]

## Twitter subscriber
Service for running and filtering data for specific cities for tweet activity

sudo service twittersubscriber [start|stop|restart]

## Sidekiq workers

This controls the sidekiq workers

sudo service sidekiq [start|stop|restart]

## Push server

This controls sending out the push notifications

sudo service push [start|stop|restart]

# Instances running

## Realtime instance

- twitter
- tweet activities
- push

## Data processing instance

- redis server
- sidekiq (high priority queue)

## Api instance

- web server
- nginx
- unicorn

## Image processing instance

You need to have setup Opencv

prerequisites:
Ubuntu instances:
1. sudo apt-get install libopencv-dev python-opencv imagemagick

since server don't have cameras set this to null for every server instance
sudo ln /dev/null /dev/raw1394

Mac OS development:
1. brew update
2. brew install opencv
3. gem install ruby-opencv

====================================================================
Setup Steps for Linux Environment
1. Clone the repository
2. Select the ruby version 2.2.2. Rvm use is recommended.
3. set the config and database file.
4. Run the command Bundle install to install the gems.
5. Make sure redis server is running
6. Make sure Postgresql version >= 9.4. If not Update it. For details see http://no0p.github.io/postgresql/2014/03/29/upgrading-pg-ubuntu.html
7. run rake db:Setup
8. Open a new tab and run sidekiq
9. need to have db_dump to populate the database.
10. Run the command rake eventful:process_new_events to generate the events for next 5 days.

## Required keys for .ENV file

EVENTFUL_API_KEY=
TWITTER_API_KEY=
INSTAGRAM_API_KEY=
INSTAGRAM_API_SECRET=
RAILS_ENV=
TWITTER_CONSUMER_KEY=
TWITTER_CONSUMER_SECRET=
TWITTER_OAUTH_TOKEN=
TWITTER_OAUTH_TOKEN_SECRET=
REDIS_PATH=
REDIS_TEST_PATH=
DROPBOX_APP_KEY=
DROPBOX_APP_SECRET=
DROPBOX_OAUTH_TOKEN=
S3_BUCKET_NAME=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
TWILIO_NUMBER=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
SMTP_ADDRESS=
SMTP_DOMAIN=
SMTP_PASSWORD=
SMTP_USERNAME=
IOS_PUSH_CERTIFICATE_FILENAME=
IOS_PUSH_ENVIRONMENT=
GCM_AUTH_KEY=

# Pulsr architecture

There are 4 main types of instances in the whole pulsr service

1. web server
2. sidekiq worker instance
3. realtime data instance
4. data processing instance

Besides these instances there is running aws rds postgres database, aws hosted redis server and elastic search server

1. WEB SERVER

Web server is running on unicorn server that is being run as init service together with nginx.
Services:
- nginx
- unicorn

2. SIDEKIQ

Sidekiq is a dedicated instance running only sidekiq workers. It is done through aws opsworks to autoscale when needed between min 1 and max 5 instances depending on the resource usage. Recipes for the opsworks are within https://github.com/PulsrApp/cookbooks
Services:
- sidekiq

3. REALTIME DATA

Real time data is processing the incoming data from twitter stream that pushes them to redis pubsub channels for further processing. It saves every tweet for the next 5 days before they are purged from db. On the same instance it is running a process that goes over receiving pushed tweets and parse them for the activity bubbles and also saves the tweets that belongs to a zone that is supported by the pulsr and extracts the photos if they contain one.
It also runs push server instance for pushing notifications to the mobile apps.
Services:
- twitter
- tweet activities
- push

4. DATA PROCESSING

Data processing instance takes care of all the heavy load tasks that need to be processed and can take some time to be processed. It is also running the elastic search server for full text search support.
Tasks:
- Process pending venues
- Process pending events
- Daily eventful import
- Weekly eventful import
- Zoning of new events
- Zoning of new venues
- Processing tastes by the city
- Recommendation processing for the next 7 days

Development environment

Requirements:
- postgres server with postgis plugin
- redis server
- elastic search server