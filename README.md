Documentation files of `https://inferenstar.com`.

# How to test quickly ?

## Start a terminal with:
```
  $ gem install sinatra
  $ ruby simple_events_catcher/sinatra.rb # this listening on localhost:4567
```
this will listen to the answers of our API.

## Start another terminal with:
```
  $ ngrok http 4567 # copy address: http://xxxxxxx.ngrok.io
```

## Send command lines:

```
  $ vim {ruby,python,curl}/send_event.xx # and replace ngrok line
  $ export X_API_KEY='...'
  $ {ruby,python...} {ruby,python...}/send_event.xx
```

