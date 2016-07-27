# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

ElasticSearch is fantastic at dealing with point based time data but is not setup to elegantly deal with time spans. This is a plugin for logstash that allows data based on a time range to be split in to
multiple records incremented per day so that it can be used within ES.

## Example
Suppose you have data structured as per the CSV line below:
```
2/3/2016,5/3/2016,Message
````
Using this plugin the data can be split in to the following lines (first token is @timestamp within ES):
```csv
2/3/2016,2/3/2016,5/3/2016,Message
3/3/2016,2/3/2016,5/3/2016,Message
4/3/2016,2/3/2016,5/3/2016,Message
5/3/2016,2/3/2016,5/3/2016,Message
```

## Logstash Config
This plugin is really basic, it assumes a start date and end date field where start is before end. Given both are assumed to be dates the input may need to be converted prior to using this plugin.
```ruby
input {
	file {
		path => "afile.csv"
		type => "core2"
		start_position => "beginning"
	}
}

filter {
	csv {
		columns => ["Start","End","message"]
		separator => ","
	}
	date {
		match => ["Start", "d/M/YYYY"]
	}
	date {
		match => ["Start", "d/M/YYYY"]
		target => "Start"
	}
	date {
		match => ["End", "d/M/YYYY"]
		target => "End"
	}
	time_split {
		start => "Start"
		end => "End"
	}
}

output {
	elasticsearch {
		action => "index"
		hosts => ["localhost"]
		index => "logstash-%{+YYYY.MM.dd}"
		workers => 1
	}
}
```
## Sanity Warning
Logstash is fast moving development so plugin development, in my experience, seems very tide to the version of logstash used. If you are having difficultly installing and get an unholly stack trace I'd first look within the 'logstash-filter-time-split.gemspec' file for the following line:
```ruby
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 1.20.0"
  ```
  This gem *must* match that used within your version of logstash. If you find this doesn't match then change it but for the love of God re-run the tests, you may find further issues.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-time-split", :path => "/your/local/logstash-time-split"
```
- Install plugin
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-time-split.gemspec
```
- Install the plugin from the Logstash home
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.