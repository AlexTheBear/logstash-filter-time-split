# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/time_split"
require "logstash/timestamp"
require "logstash/event"

require "date"

describe LogStash::Filters::Time_Split do

  describe "all normal" do
    config <<-CONFIG
      filter {
        time_split {
          start => "start"
          end => "end"
        }
      }
    CONFIG

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

  describe "wrong way round" do
    config <<-CONFIG
      filter {
        time_split {
          start => "start"
          end => "end"
        }
      }
    CONFIG

    sample("start" => LogStash::Timestamp.new(Time.new(2016,1,14)), "end" => LogStash::Timestamp.new(Time.new(2016,1,12)), "replicated" => "some string") do
      insist { subject.length } == 3
      subject.each do |s|
        insist { s["replicated"] } == "some string"
      end
      insist { subject[0]["@timestamp"].to_s } == LogStash::Timestamp.at(Time.new(2016,1,12)).to_s
      insist { subject[1]["@timestamp"].to_s } == LogStash::Timestamp.at(Time.new(2016,1,13)).to_s
      insist { subject[2]["@timestamp"].to_s } == LogStash::Timestamp.at(Time.new(2016,1,14)).to_s
    end
  end

  context "when invalid type is passed" do
      let(:filter) { LogStash::Filters::Time_Split.new({"start" => "start", "end" => "end"}) }
      let(:logger) { filter.logger }
      let(:event) { event = LogStash::Event.new({"field" => "not-a-date","end" => "not-a-date"}) }

      before do
        allow(filter.logger).to receive(:warn).with(anything)
        filter.filter(event)
      end

      it "should log an error" do
        expect(filter.logger).to have_received(:warn).with(/Only dates types are splittable/)
      end

      it "should add a '_time_split_type_failure' tag" do
        expect(event["tags"]).to include(LogStash::Filters::Time_Split::PARSE_FAILURE_TAG)
      end
  end

  context "when field is nil" do
      let(:filter) { LogStash::Filters::Time_Split.new({"start" => "start", "end" => "end"}) }
      let(:logger) { filter.logger }
      let(:event) { event = LogStash::Event.new({"field" => nil,"end" => nil}) }

      before do
        allow(filter.logger).to receive(:warn).with(anything)
        filter.filter(event)
      end

      it "should log an error" do
        expect(filter.logger).to have_received(:warn).with(/Only dates types are splittable/)
      end

      it "should add a '_time_split_type_failure' tag" do
        expect(event["tags"]).to include(LogStash::Filters::Time_Split::PARSE_FAILURE_TAG)
      end
  end
end
