# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/time_split"
require "logstash/timestamp"
require "logstash/event"

require "date"

describe LogStash::Filters::Time_Split do

  describe "all defaults" do
    config <<-CONFIG
      filter {
        time_split {
          start => "start"
          end => "end"
        }
      }
    CONFIG
###
    sample("start" => Time.new(2016,7,12), "end" => Time.new(2016,7,14), "replicated" => "some string") do
      insist { subject.length } == 3
      subject.each do |s|
        insist { s.get("replicated") } == "some string"
      end
      insist { subject[0].get("@timestamp") } == LogStash::Timestamp.at(Time.new(2016,7,12))
      insist { subject[1].get("@timestamp") } == LogStash::Timestamp.at(Time.new(2016,7,13))
      insist { subject[2].get("@timestamp") } == LogStash::Timestamp.at(Time.new(2016,7,14))
    end
  end
end
