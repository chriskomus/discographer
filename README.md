# DISCOGRAPHER

Import Data from the Discogs API into a Database using Ruby on Rails.

Uses [Discogs Wrapper for Ruby on Rails](https://github.com/buntine/discogs) to authenticate and interact with the Discogs API.

# Features
* Import an artist or record label's entire discography from Discogs' API with one click.
* Import individual albums from Discogs.
* Manually add new artists, labels, albums etc and by using a Discogs id, then pull data and image uris from Discogs.
* Album pages contain embedded videos, plus links to associated artist, genres, and record labels.
* Search filters on each page. 

# Importing From Discogs into a Database with Ruby on Rails

Imported album contains:
* Cover art
* Embedded videos
* Track listing
* Genres
* Artists
* Associated labels and releases/reprints

# Getting Started
* `bundle install`
* `rake db:drop db:create db:schema:load`
* Use [127.0.0.1](http://127.0.0.1:3000/) or another valid address to prevent session issues. Don't use localhost.
* Create an app on Discogs.com via your [developer console](https://www.discogs.com/settings/developers).
* Add the "Consumer Key" and "Consumer Secret" into /config/environment_variables.yml
* Edit the /db/seeds.rb file to import some Discogs data into the database. This should be done after authenticating, otherwise image uris will not import.
* `rake db:seed`

To import an album, artist, or label:
* Create a new album, artist, or label and save it with the associated discogs id, which can be found in the url on the discogs website. (ie: https://www.discogs.com/release/3336).
* Click 'Import from Discogs' after it has been created. When importing an album, all associated tracks, videos, artists, genres, labels and releases will be imported as well.

To import all albums from a label or artist:
* Either create or navigate to either the label or artist page.
* Click 'Import all albums from this label'. This can take awhile and tends to work best for small labels or artists with only a few releases.
* If the artist or label has a lot of releases, this will be time consuming (Discogs only allows 60 requests per minute when authenticated) and could potentially take you down a rabbit hole of data! If an album has many re-releases on many labels, it will import profile pages for all the labels and associated artists for that album.

# Seeds.rb

Use the seed file to fill the database with the entire discography of an array of labels or artists. In order to import links to images, authenticate first. Otherwise none of the image uris will import. This can be fixed afterwards by going to the '/import/import_all_imageuris' route.
 

# Config

Store env variables in: config/application.yml

Add config/application.yml to .gitignore

# Gems

Bootstrap: `gem 'bootstrap'`

Figaro - for setting environment variables: `gem "figaro"`

Discogs Wrapper - for interacting with the Discogs API: `gem "discogs-wrapper"`

Active Record Session Store - for storing tokens: `gem 'activerecord-session_store'`

# Screenshots

## Album Page
Contains album art, track listing, embedded video links and associated artists, labels, and releases (catalog numbers).

![Album Page](https://github.com/chriskomus/discographer/blob/main/app/assets/images/readme_3.jpg?raw=true)

## Artist Listings
Contains a list of all artists, with search box.

![Artist Listings](https://github.com/chriskomus/discographer/blob/main/app/assets/images/readme_1.jpg?raw=true)

## Artist Profile
Contains all albums and labels associated with an artist.

![Artist Profile](https://github.com/chriskomus/discographer/blob/main/app/assets/images/readme_2.jpg?raw=true)

## Album Listings
Contains all albums, with search box.

![Album Listings](https://github.com/chriskomus/discographer/blob/main/app/assets/images/readme_4.jpg?raw=true)

## Album Releases
An album may have been released multiple times or on multiple labels. This page shows all releases and their catalog number.

![Album Releases](https://github.com/chriskomus/discographer/blob/main/app/assets/images/readme_5.jpg?raw=true)


## Genre Listings
Contains a list of all genres. Click a genre to see all albums associated with that genre.

![Genre Listings](https://github.com/chriskomus/discographer/blob/main/app/assets/images/readme_6.jpg?raw=true)