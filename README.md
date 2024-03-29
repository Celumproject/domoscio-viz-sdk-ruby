# DomoscioViz

This README would document whatever steps are necessary to get the DomoscioViz Ruby SDK up and running.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

DomoscioViz 1.1.3 works with Rails 3.2 onwards.

### Installing

Add it to your Gemfile with:

```ruby
gem 'domoscio_viz', '0.2.0', git: 'git://github.com/Celumproject/domoscio-viz-sdk-ruby', branch: 'master'
```

Then run `bundle install`

Next, you need to run the generator:

```console
$ rails generate domoscio_viz:install
```

Then you have to configure the `ENV['DOMOSCIO_ID']` and `ENV['DOMOSCIO_PASSWORD']` with your credentials to access your enabled APIs. Refer to the API documentation for details:
https://domoscio.com/wiki/doku.php?id=api2:start

```ruby
DomoscioViz.configure do |c|
    c.client_id = ENV['DOMOSCIO_ID']
    c.client_passphrase = ENV['DOMOSCIO_PASSWORD']
    c.temp_dir = File.expand_path('../tmp', __FILE__)
    FileUtils.mkdir_p(c.temp_dir) unless File.directory?(c.temp_dir)
end
```

| Key  | Type | Description |
| ------------- | ------------- | ------------- |
| client_id  | `integer` | this is your instance_id, required for access to your data |
| client_passphrase  | `string` | client_passphrase is your secret key, this token is paired with your client_id |

## Basic DomoscioViz use

### Get Url

Server request need 2 strongs parameters :  
    - First argument is the url of the chart requested.  
    - Second argument are the data (billing or optional).  

In `your controller`:

```ruby
@chart_url = DomoscioViz::Chart.get_url("obj_mastery", {chart: "polar", objective_id: 1, student_id: 1})["url"]
```

Then pass this url in the `following view`:

```html
<iframe src="<%= @chart_url %>" sandbox="allow-same-origin allow-scripts allow-popups allow-forms"></iframe>
```

## Versioning

Currently v0.2.0

## Authors

See the list of contributors (https://github.com/Celumproject/domoscio_js/contributors)

This project rocks and uses MIT-LICENSE.
