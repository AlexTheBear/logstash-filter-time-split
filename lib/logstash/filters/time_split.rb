# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/timestamp"

require "date"

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
  def invalidDate(*times)
    return true if times.length==0
    return true if times.length==1 && times[0]==nil
    return !times[0].is_a?(LogStash::Timestamp) if times.length==1

    all_valid = true;
    times.each do |time|
      all_valid &= invalidDate(time)
    end

    return all_valid
  end

  private
  def sort(start,finish)
    return finish, start if start>finish

    return start, finish
  end

  public
  def filter(event)
    start_time = event[@start]
    end_time = event[@end]

    if invalidDate start_time, end_time
      logger.warn("Only dates types are splittable")

      event.tag(PARSE_FAILURE_TAG)
      return
    end

    start_time = toDate(start_time)
    end_time = toDate(end_time)

    start_time, end_time = sort start_time, end_time

    start_time.step(end_time,1).each do |value|
      event_split = event.clone

      event_split["@timestamp"]=LogStash::Timestamp.at(value.to_time)

      yield event_split
    end

    # Cancel this event, we'll use the newly generated ones above.
    event.cancel
  end # def filter
end # class LogStash::Filters::Split
