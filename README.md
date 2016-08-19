# Flatten

A Ruby Gem to Flatten Nested JSON 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flatten'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flatten

## Usage

Given a nested hash or a nested json string, run the smash method on it and get a flattened json string.


```ruby
Loading development environment (Rails 4.2.5)

irb(main):037:0> ap my_house
{
    "property" => {
        "dunwoody-home" => {
            "dh-description" => "my house in dunwoody",
                   "address" => {
                "dh-street" => "5252 vernon lake drive",
                  "dh-city" => "atlanta",
                 "dh-state" => "GA"
            }
        }
    },
        "name" => "lex"
}

irb(main):038:0> ap my_house.smash
{
    "dh-description" => "my house in dunwoody",
         "dh-street" => "5252 vernon lake drive",
           "dh-city" => "atlanta",
          "dh-state" => "GA",
              "name" => "lex"
}

```


## Assumptions

This assumes that every key is unique.

Something like this is not supported:  `{"name":"lex", "property": {"name":"house"}}`

## Notes

I used the awesome_print gem in the example:  https://github.com/awesome-print/awesome_print


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/l3x/flatten.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

