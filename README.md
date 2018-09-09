# Dashboard Control

Configure lists of URLs to be cycled through. Many lists can be set up.
Configuration is set up in the `config/dashboards.yml` file.

Extra configuration can be set up in the `config/text_contents.yml` file.

There are two special URLs for use by dashboards which are served by this application.

* `/text/{slug}` - loads text from the `text_contents.yml` file from the `{slug}` section. Text is centred horizontally.
* `/image/{slug}` - loads the image stored in `public/images` with a filename exactly matching `{slug}`.

## Dashboard config

Each dashboard has a key (which matches the parameter at the end of the `/dashboard/` URL.
Each section for a key has a `description` and a `boards` entry.
The `boards` entry is an array of URL and duration entries.

e.g.
~~~{.yml}
ph2:
  description: Pack house number 2
  boards:
    - url: http://localhost:3030/rejections_ph2
      secs: 35
    - url: http://localhost:9292/image/IMGP2219.JPG
      secs: 10
    - url: http://localhost:9292/text/notes
      secs: 30
~~~

This will be used to display the dashboards at URL `/dashboard/ph2`.

## Text config

Each text page has a key (which matches the parameter at the end of the `/text/` URL.
Each section for a key has an array of entries.
Each entry has a `text` element and optionally `colour` and `size` elements.
Colour must be a valid css `color` value. The default is black.
Size can be any number above zero. The bigger the number the bigger the text. Decimal values are allowed.

e.g.
~~~{.yml}
notes:
  - text: PACKHOUSES
    size: 6
    colour: navy
  - text: All shifts now get an extra 5 minutes smoke break every 2nd break
    size: 3
    colour: blue
~~~

This will display the text above at URL `/text/notes`.

## Install

    bundle install

## Run

    rackup

