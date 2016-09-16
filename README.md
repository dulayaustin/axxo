Axxo
================

This application is for scrapping the contents of [Axxo Movies](http://axxomovies.org)


Ruby on Rails
-------------

This application requires:

- Ruby 2.3.0
- Rails 5.0.0.1


Getting Started
---------------

After you pull this repo, in to your terminal go to this application directory then run the ff.:

1. `rake db:create`
2. `rake db:migrate`
3. `rake axxo:fetch_records`
    
      This task is for fetching the title, link, and genre of movies from last pagination to [root page](http://axxomovies.org).

4. `rake axxo:get_specific_details`

      After fetching records, this task will get the _image_, _torrent_, _youtube_url_ and also additional _information_ like plot, imdb/ratings link, size, quality and language if there has any.

      Modify error links by trimming the links if it has valid or none existing link

      _This will take too long to finish!_



Issues
---------------

- Slow fetching records task `rake axxo:get_specific_details`
- Slow rendering queries, N+1 issue

