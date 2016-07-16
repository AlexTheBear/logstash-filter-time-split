# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/timestamp"

require "date"

# The split filter clones an event by splitting one of its fields and
# placing each value resulting from the split into a clone of the original
# event. The field being split can either be a string or an array.
#
# An example use case of this filter is for taking output from the
# <<plugins-inputs-exec,exec input plugin>> which emits one event for
# the whole output of a command and splitting that output by newline -
# making each line an event.
#
# Split filter can also be used to split array fields in events into individual events.
# A very common pattern in JSON & XML is to make use of lists to group data together.
#
# For example, a json structure like this:
#
# [source,js]
# ----------------------------------
# { field1: ...,
#  results: [
#    { result ... },
#    { result ... },
#    { result ... },
#    ...
# ] }
# ----------------------------------
#
# The split filter can be used on the above data to create separate events for each value of `results` field
#
# [source,js]
# ----------------------------------
# filter {
#  split {
#    field => "results"
#  }
# }
# ----------------------------------
#
# The end result of each split is a complete copy of the event
# with only the current split section of the given field changed.
class LogStash::Filters::Time_Split < LogStash::Filters::Base
  PARSE_FAILURE_TAG = '_time_split_type_failure'.freeze

  config_name "time_split"

  # The field from which we'll take the start time, this is expected to
  # be a date type
  config :start, :validate => :string

  # The field from which we'll take the end time, this is expected to
  # be a date type
  config :end, :validate => :string

  public
  def register
    # Nothing to do
  end # def register

  private
  def toDate(time)
    Date.parse(time.to_s)
  end

  private
  def invalidDate(time)
    !time.is_a?(LogStash::Timestamp)
  end

  public
  def filter(event)
    start_time = event[@start]
    end_time = event[@end]

    if invalidDate(start_time) || invalidDate(end_time)
      logger.warn("Only dates are types are splittable")
      puts "WRONG FORMAT"
      event.tag(PARSE_FAILURE_TAG)
      return
    end

    start_time = toDate(start_time)
    end_time = toDate(end_time)

    start_time.step(end_time,1).each do |value|
      event_split = event.clone

      event_split["@timestamp"]=LogStash::Timestamp.at(value.to_time)

      yield event_split
    end

    # Cancel this event, we'll use the newly generated ones above.
    event.cancel
  end # def filter
end # class LogStash::Filters::Split
