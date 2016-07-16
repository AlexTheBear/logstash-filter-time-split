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
    sample("start" => LogStash::Timestamp.new(Time.new(2016,1,12)), "end" => LogStash::Timestamp.new(Time.new(2016,1,14)), "replicated" => "some string") do
      insist { subject.length } == 3
      subject.each do |s|
        insist { s["replicated"] } == "some string"
      end
      insist { subject[0]["@timestamp"].to_s } == LogStash::Timestamp.at(Time.new(2016,1,12)).to_s
      insist { subject[1]["@timestamp"].to_s } == LogStash::Timestamp.at(Time.new(2016,1,13)).to_s
      insist { subject[2]["@timestamp"].to_s } == LogStash::Timestamp.at(Time.new(2016,1,14)).to_s
    end
  end
end
