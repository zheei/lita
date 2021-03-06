# Lita

[![Gem Version](https://badge.fury.io/rb/lita.png)](http://badge.fury.io/rb/lita)
[![Build Status](https://travis-ci.org/jimmycuadra/lita.png?branch=master)](https://travis-ci.org/jimmycuadra/lita)
[![Code Climate](https://codeclimate.com/github/jimmycuadra/lita.png)](https://codeclimate.com/github/jimmycuadra/lita)
[![Coverage Status](https://coveralls.io/repos/jimmycuadra/lita/badge.png)](https://coveralls.io/r/jimmycuadra/lita)

**Lita** is a chat bot written in [Ruby](https://www.ruby-lang.org/) with persistent storage provided by [Redis](http://redis.io/). It uses a plugin system to connect to different chat services and to provide new behavior. The plugin system uses the familiar tools of the Ruby ecosystem: [RubyGems](https://rubygems.org/) and [Bundler](http://gembundler.com/).

Automate your business and have fun with your very own robot companion.

## Documentation

Please visit [lita.io](https://www.lita.io/) for comprehensive documentation.

## Plugins

A list of all publicly available Lita plugins is available on the [lita.io plugins page](https://www.lita.io/plugins).

The plugins page automatically updates daily with information from RubyGems. See [publishing](https://www.lita.io/plugin-authoring#publishing) for more information.

## Contributing

See the [contribution guide](https://github.com/jimmycuadra/lita/blob/master/CONTRIBUTING.md).

## History

For a history of releases, see the [Releases](https://github.com/jimmycuadra/lita/releases) page.

## License

[MIT](http://opensource.org/licenses/MIT)

## Slack (with Heroku) install tips

[deploy page](http://docs.lita.io/getting-started/deployment/#heroku)

* Add redis:
`heroku addons:create redistogo`
Add credit card required.

* Lita keep connect to 127.0.0.1:
`heroku config:set REDIS_URL=YOUR_SETTING_FROM_HEROKU_ADDON`

* Useful to get debug info:
`heroku run lita`

* Getting "fatal: Not a git repository (or any of the parent directories)" when building and starting app.
Basically check if 'git' was called at any point in your app. (From: https://groups.google.com/forum/#!topic/heroku/dv8ZlllNafA)
