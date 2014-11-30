gripst
======
Is GitHub's Gist search not enough? Brute-force grep all your gists.

## Installation

[Create an access token for GitHub](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
```
$ gem install gripst
$ export GITHUB_USER_ACCESS_TOKEN=your_access_token_from_above
```

## Usage

```
gripst "(stuff|things)"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Tests

```
git clone git@github.com:maxbeizer/gripst.git
rake install
rake spec
```

## Credits

This Ruby script was originally written by [James White](https://github.com/jameswhite/).

## License

MIT
