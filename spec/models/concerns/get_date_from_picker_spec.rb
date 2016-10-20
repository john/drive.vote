require 'spec_helper'

shared_examples_for 'get_date_from_picker' do

  # TODO: implement soon
  describe 'for ride' do
    let(:model) { described_class } # the class that includes the concern
    let(:instance_to_get_date_from) { FactoryGirl.create(model.to_s.underscore.to_sym) }

    context 'pickup_day or pickup_time have changed' do
      it "should change pickup_at" do
      end

      it "should account for time zone difference" do
      end
    end

    context "pickup_day is changed, pickup_time is nil" do
      it "should not populate pickup_at" do
      end
    end

    context "pickup_time is present, pickup_day is nil" do
      it "should not populate pickup_at" do
      end
    end
  end

  # TODO: implement after we've refactored Conversation.pickup_time to pickup_at
  describe 'for conversation' do
    let(:model) { described_class } # the class that includes the concern
    let(:instance_to_get_date_from) { FactoryGirl.create(model.to_s.underscore.to_sym) }

    context 'pickup_day or pickup_time have changed' do
      it "should change pickup_at" do
      end

      it "should account for time zone difference" do
      end
    end

    context "pickup_day is changed, pickup_time is nil" do
      it "should not populate pickup_at" do
      end
    end

    context "pickup_time is present, pickup_day is nil" do
      it "should not populate pickup_at" do
      end
    end
  end
  end

end