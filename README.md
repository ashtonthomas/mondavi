# Mondavi

Welcome to Mondavi!

Mondavi is a gem to help you cleanly structure code within your napa-based microservices, manage your dependencies and keep your interfaces clean.

Mondavi urges you to structure the building blocks of a service into a "component".
- A component cannot be too small.
- A component has a clean, Grape-based API
- A service/server is a collection of highly cohesive components (if you want)
- Components on the same service/server talk to each other via their Grape-based API (via mocked Rack requests)
- Components communicate to external components (on a different service/server) via similar Grape API's (but with a real HTTP request)
- Mondavi systems should have a shared library for (can just live in lib/ until mutliple services are needed):
  - A simple file corresponding to each api file in each component (only has method name and url variables - not full URL)
  - Shared representers (same file to serialize on producer as the consumer uses to parse)
  - Pacts for each api. A file for each api with a list of possible method, url_variables along with the expected responses
    - When testing a component in isolation, the pacts are returned when other components are called
    - When developing, the pacts are returned when calling out to external components (the mock Rack request is still used for communicating with local components)
  - Helping evolve producer API's without immediately breaking
    - Adding required url_variable
    - Deprecating an api (concept/resource) or an available method
- Mondavi systems communicate by using url_tempaltes (as opposed to hard coded, hard to change urls)
  - There should exist an IndexComponent
  - The complete url to the IndexComponent is the only thing that is exposed to 'clients'
  - The IndexComponent has one api IndexComponent::IndexApi (the class defined in the shared library)
  - The implementing IndexComponent::IndexApiImpl (the class defined in the actual producing component), is the only part that needs to know the url's of all the other components
    - IndexComponent::IndexApiImpl makes a call to every other component (since it knows the urls) and
    - builds a complete index/service-document/manifest file
    - IndexComponent::IndexApiImpl calls the corredsponding [Foo]Component::IndexApi (it uses the class defined in the shared library) for each component
    - Therefore, each component must have: [Foo]Component::IndexApiImpl which returns the manifest for its apis
      - an entry for each method and templates for url and urn_path
        - urn_path is seperate from url as we only need urn_path for local requests

[Here](https://github.com/ashtonthomas/pet-store) is an example application using Mondavi

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mondavi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mondavi

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ashtonthomas/mondavi.

