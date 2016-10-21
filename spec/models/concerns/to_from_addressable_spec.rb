require 'spec_helper'

shared_examples_for 'to_from_addressable' do

  describe 'after_validation geocode' do
    let(:model) { described_class } # the class that includes the concern
    let(:addressable_instance) { FactoryGirl.create(model.to_s.underscore.to_sym) }

    context 'lat/log have changed' do

      # if lat/long is getting changed, no need to run geocoder
      it 'should not be called' do
        addressable_instance.to_latitude = 90
        addressable_instance.to_longitude = 90
        addressable_instance.from_latitude = -90
        addressable_instance.from_longitude = -90
        addressable_instance.to_address = '1234 Street'
        addressable_instance.from_address = '5678 Ave'

        expect(addressable_instance).to_not receive(:geocode_to)
        expect(addressable_instance).to_not receive(:geocode_from)

        addressable_instance.valid?
      end
    end

    context 'address changed, but lat/log has not changed' do
      context 'to address changes' do
        it 'should be called' do
          addressable_instance.to_address = '1234 Street'
          addressable_instance.to_city = 'Tampa'

          expect(addressable_instance).to receive(:geocode_to)
          expect(addressable_instance).to_not receive(:geocode_from)

          addressable_instance.valid?
        end
      end

      context 'from address changes' do
        it 'should be called ' do
          addressable_instance.from_address = '5678 Ave'
          addressable_instance.from_city = 'Tampa'

          expect(addressable_instance).to receive(:geocode_from)
          expect(addressable_instance).to_not receive(:geocode_to)
          addressable_instance.valid?
        end
      end

      context "has from address, but no city or state" do
        it 'should not be called' do
          addressable_instance.to_address = '1234 Street'

          expect(addressable_instance).to_not receive(:geocode_to)
          expect(addressable_instance).to_not receive(:geocode_from)
          addressable_instance.valid?
        end
      end

    end

    context 'address has not changed' do

      it 'should not be called' do
        expect(addressable_instance).to_not receive(:geocode_to)
        expect(addressable_instance).to_not receive(:geocode_from)
        addressable_instance.valid?
      end
    end
  end
end