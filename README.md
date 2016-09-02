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
3. `rake axxo:fetch_all_old_records`
    
      This task is for fetching the title, link, and genre of movies from last pagination to [page 2](http://axxomovies.org/page/2/) of [Axxo Movies](http://axxomovies.org).

4. `rake axxo:fetch_new_records`
      
      Same with the previous task, but only fetching the [root page](http://axxomovies.org).

5. `rake axxo:get_specific_details`

      After fetching records, this task will get the _image_, _torrent_, _youtube_url_ and also additional _information_ like plot, imdb link, size, quality and language if there has any.

      _This will take too long finish!_

6. `rake axxo:trim_movie_error_links`
      
      **Note:** Make sure to finish first the _get_specific_details_ task before proceeding here!

      Then trimming error links example: **http://axxomovies.org/lockout-2012-4/** to **http://axxomovies.org/lockout-2012**

      Also deleting nonexisting links like, **http://axxomovies.org/5257/**

7. `rake axxo:get_specific_details`

      Lastly get again the details of trim links


Issues
---------------

- Slow fetching records task `rake axxo:get_specific_details`
- Slow rendering queries

