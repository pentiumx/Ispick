#!/bin/bash

# Start all scraping scripts manually
RAILS_ENV=production bundle exec rake scrape:anipic[720] --silent >> log/scrape_anipic_cron.log 2>> log/scrape_anipic_error.log &
RAILS_ENV=production bundle exec rake scrape:nico[360] --silent >> log/scrape_nico_cron.log 2>> log/scrape_nico_error.log &
RAILS_ENV=production bundle exec rake scrape:tumblr[360] --silent >> log/scrape_tumblr_cron.log 2>> log/scrape_tumblr_error.log &