# Twitter voting

This is a real time voting engine that allow conference attendants to review a talk via Twitter.

This sample code was created for QCon São Paulo 2014.

## Technologies used

* Twitter Streaming API and tweetstream gem
* ruby 2.x
* Sinatra (web dashboard)
* faye-websocket (Websocket middleware)
* redis (storage)
* jQuery and Bootstrap (frontend)

## Installing and running

1. Clone this repo
2. Set up your Twitter credentials in `config/credentials.yml` with your app tokens obtained at apps.twitter.com (see `config/credentials.yml.sample`)
2. Set up your `config/agenda.yml` file with all talks, the hashtag that will trigger a vote for each one and also their attributes (see `config/agenda.yml.sample`)
3. Open `config/initializer.rb` and define:
    * Your Event hashtag (used by Twitter tracker)
    * Which words represent each level of quality (see `EVENT_REVIEW_GRADES`)
    * If you will be accepting only one vote per user (see `ACCEPT_ONLY_UNIQUE_VOTES`) 
4. Install and start redis
5. Run `bundle install` to set up environment
6. Run `foreman start`
7. Access `http://localhost:3000` in your browser
8. Vote! ex.: _"#qconsp #twitterapi #good awesome talk"_

Try to vote to a talk while having it's permalink page open.

Have fun!

## Contributions 

This is a demo app, so if you are thinking to use in production, please review and test this code properly.

Some features could be added (if you wish):

* Automatic review detection (without using keyword matching)
* Optimize the way websockets connections are used (to avoid unnecessary messages)
* Add a tweet timeline to each talk permalink page with each review (encourage fearless communication)

(2014) Luis Cipriani. This code is under Apache License.
