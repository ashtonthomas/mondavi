# Mondavi

Welcome to Mondavi!

Mondavi is a gem to help you cleanly structure code within your [napa](https://github.com/bellycard/napa)-based microservices, manage your dependencies and keep your interfaces clean.

Mondavi urges you to structure the building blocks of a service into a "component".
- A component cannot be too small.
- A component has a clean, [grape](https://github.com/ruby-grape/grape)-based API
- A service/server is a collection of highly cohesive components (if you want)
- Components on the same service/server talk to each other via their Grape-based API (via [mocked Rack requests](https://github.com/ashtonthomas/mondavi/blob/master/lib/mondavi/request_router.rb#L108-L144))
- Components communicate to external components (on a different service/server) via similar Grape API's ([but with a real HTTP request](https://github.com/ashtonthomas/mondavi/blob/master/lib/mondavi/request_router.rb#L96-L106))
- Mondavi systems should have a shared library for ([can just live in lib/ until mutliple services are needed](https://github.com/ashtonthomas/pet-store/tree/master/lib/components_api)):
  - Interfaces: A simple file corresponding to each api file in each component (only has method name and url variables - not full URL) [example](https://github.com/ashtonthomas/pet-store/blob/master/lib/components_api/doggy/api/dog_api.rb)
    - these files correspond to the files in each implementing component and end with "Impl": [example](https://github.com/ashtonthomas/pet-store/blob/master/components/doggy/apis/dog_api_impl.rb)
  - Representer: Shared representers (same file to serialize on producer as the consumer uses to parse) [example](https://github.com/ashtonthomas/pet-store/blob/master/lib/components_api/doggy/representers/dog_representer.rb)
  - Pacts: Expectations for each api. A file for each api with a list of possible method, url_variables along with the expected responses: [example](https://github.com/ashtonthomas/pet-store/blob/master/lib/components_api/doggy/pacts/dog_api_pact.rb)
    - When testing a component in isolation, the pacts are returned when other components are called
    - When developing, the pacts are returned when calling out to external components (the mock Rack request is still used for communicating with local components)
  - Exceptions: which may get thrown, parsed, re-raised (well, that may be a bad sign, code smell)
- Mondavi helps evolve producer API's without immediately breaking consumers
  - Changing the order of url_parameters is requires zero effort on the consumer
  - Changing the url (moving the component to a new server) also requires zero effort on the consumer
  - Adding required url_variable (optional_until: DATE -> creates an alert when the consumer calls this method)
  - Deprecating an api (concept/resource) or an available method (deprecated_on: PAST_DATE, supported_until: FUTURE_DATE)
- Mondavi systems communicate by using url_tempaltes (as opposed to hard coded, hard to change urls)
  - There should exist an IndexComponent
  - The complete url to the IndexComponent is the only thing that is exposed to 'clients'
  - The IndexComponent has one api IndexComponent::IndexApi (the class defined in the shared library)
  - The implementing [IndexComponent::IndexApiImpl](https://github.com/ashtonthomas/pet-store/blob/master/components/index/apis/index_api_impl.rb) (the class defined in the actual producing component), is the only part that needs to know the url's of all the other components
    - IndexComponent::IndexApiImpl makes a call to every other component (since it knows the urls) and
    - builds a complete index/service-document/manifest file
      - here is an [example of this in a helper object](https://github.com/ashtonthomas/pet-store/blob/master/components/index/build_index.rb)
    - IndexComponent::IndexApiImpl calls the corredsponding [[Foo]Component::IndexApi](https://github.com/ashtonthomas/pet-store/blob/master/lib/components_api/doggy/api/index_api.rb) (it uses the class defined in the shared library) for each component
      - _note: this follows a consitent pattern and these interfaces can be generated_
    - Therefore, each component must have: [[Foo]Component::IndexApiImpl](https://github.com/ashtonthomas/pet-store/blob/master/components/doggy/apis/doggy_index_api_impl.rb) which returns the manifest for its apis
      - _note: this can actually be generated based on the Grape api - so no work should be needed_
      - an entry for each method and templates for url and urn_path
        - urn_path is seperate from url as we only need urn_path for local requests
- Each application/service/server will have an [apis/applicatiion_api](https://github.com/ashtonthomas/pet-store/blob/master/app/apis/application_api.rb) which mounts all the local components
  - _note: this can also be generated, so this can go away_
- If you wanted, you could have a 'misc' app/service/server for a collection of components that don't belong anywere else
  - This may save on infrastructure costs as well as maintenance costs
  - However, sticking an expiremental or weird component on any other somewhat related app is fine as it is well contained and can be moved whenever..
-


[Here](https://github.com/ashtonthomas/pet-store) is an example application using Mondavi

Mondavi is about:
- Managing dependencies (nothing should ever call into another component's files - only via the api)
- Mocking tests when external services are involved
- Flexibility when modifying an API (don't let your api consumers strangle you)
- Consistency: the same file to serialize/parse a response
- Consistency: mocks used by consumers are the same expectations set on the producing api
- Expiremental components can be added, evovled, and completed moved (with no changes to consumers)
- Being able to erase and re-draw the lines around your services


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

