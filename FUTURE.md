## List all saved events for the next 6 days

curl -X "GET" "http://staging.pulsr.com/api/account/saved_events.json" \
  -H "Access-Token: qYE-omF_qxp2zPhgfN_A"

## List all upcoming hidden events

curl -X "GET" "http://staging.pulsr.com/api/account/hidden_events.json" \
  -H "Access-Token: qYE-omF_qxp2zPhgfN_A"

## List all saved events for the next 6 days

curl -X "GET" "http://staging.pulsr.com/api/account/saved_events.json" \
  -H "Access-Token: qYE-omF_qxp2zPhgfN_A"

## List all upcoming hidden events

curl -X "GET" "http://staging.pulsr.com/api/account/hidden_events.json" \
  -H "Access-Token: qYE-omF_qxp2zPhgfN_A"

## Event Voting

Like the event

curl -X "POST" "http://staging.pulsr.com/api/events/10/like" -H "Access-Token: B7xcsh1rhiNGEY7X6Vx6"

Dislike the event

curl -X "POST" "http://staging.pulsr.com/api/events/10/dislike" -H "Access-Token: B7xcsh1rhiNGEY7X6Vx6"

## User save event

User can save event to saved list

curl -X "POST" "http://staging.pulsr.com/api/events/6370/save.json?date=2015-10-02%2016%3A03%3A51%2B00%3A00" \
  -H "Access-Token: qYE-omF_qxp2zPhgfN_A"

Date value should be the same as the value of starts_at for the event you are trying to save


## Get list of users that hidden event

curl -X "GET" "http://staging.pulsr.com/api/events/6370/hidden.json" \
  -H "Access-Token: qYE-omF_qxp2zPhgfN_A"

