require 'spec_helper'
require 'bitcoin_data_parser'

RSpec.describe BitcoinDataParser do
  context 'Parse Bitcoin data' do
    context 'without parameters' do
      it 'validate content' do
        data = BitcoinDataParser.new.parse

        expect(data.class).to eq(Array)
        expect(data.first.size).to eq(2)
        expect(data.first.first.class).to eq(String)
        expect(data.first.last.class).to eq(Float)
      end

      it 'validate date sorting in desc by default' do
        data = BitcoinDataParser.new.parse
        validation_result = []

        data.each_with_index do |(date, _price), index|
          next unless data[index + 1]

          validation_result << (Date.parse(date) > Date.parse(data[index + 1].first))
        end

        expect(validation_result).to_not include(false)
      end

      it 'validate granularity daily by default' do
        data = BitcoinDataParser.new.parse
        not_first_day_in_month_and_not_monday = data.find { |date, _price| Date.parse(date).day > 1 && !Date.parse(date).monday? }

        expect(not_first_day_in_month_and_not_monday).to_not be_nil
      end
    end


    context 'with parameters' do
      it 'validate date sorting in asc' do
        data = BitcoinDataParser.new(order_dir: :asc).parse
        validation_result = []

        data.each_with_index do |(date, _price), index|
          next unless data[index + 1]

          validation_result << (Date.parse(date) < Date.parse(data[index + 1].first))
        end

        expect(validation_result).to_not include(false)
      end

      it 'validate filter_date_from as string' do
        filter_date_from = "20#{rand(13..16)}-#{rand(1..12).to_s.rjust(2, '0')}-#{rand(1..28).to_s.rjust(2, '0')}"
        data = BitcoinDataParser.new(order_dir: :asc, filter_date_from: filter_date_from).parse

        first_date_not_less_than_filter_date = Date.parse(data.first.first) >= Date.parse(filter_date_from)

        expect(first_date_not_less_than_filter_date).to be_truthy
      end

      it 'validate filter_date_from as date' do
        filter_date_from = Date.parse("20#{rand(13..18)}-#{rand(1..12).to_s.rjust(2, '0')}-#{rand(1..28).to_s.rjust(2, '0')}")
        data = BitcoinDataParser.new(order_dir: :asc, filter_date_from: filter_date_from).parse

        first_date_not_less_than_filter_date = Date.parse(data.first.first) >= filter_date_from

        expect(first_date_not_less_than_filter_date).to be_truthy
      end

      it 'validate filter_date_to as string' do
        filter_date_to = "20#{rand(13..18)}-#{rand(1..12).to_s.rjust(2, '0')}-#{rand(1..28).to_s.rjust(2, '0')}"
        data = BitcoinDataParser.new(order_dir: :asc, filter_date_to: filter_date_to).parse

        last_date_less_than_filter_date = Date.parse(data.last.first) <= Date.parse(filter_date_to)

        expect(last_date_less_than_filter_date).to be_truthy
      end

      it 'validate filter_date_to as date' do
        filter_date_to = Date.parse("20#{rand(13..18)}-#{rand(1..12).to_s.rjust(2, '0')}-#{rand(1..28).to_s.rjust(2, '0')}")
        data = BitcoinDataParser.new(order_dir: :asc, filter_date_to: filter_date_to).parse

        last_date_less_than_filter_date = Date.parse(data.last.first) <= filter_date_to

        expect(last_date_less_than_filter_date).to be_truthy
      end

      it 'validate filter_date_from with filter_date_to as date' do
        filter_date_from = Date.parse("20#{rand(13..16)}-#{rand(1..12).to_s.rjust(2, '0')}-#{rand(1..28).to_s.rjust(2, '0')}")
        year = "20#{rand(filter_date_from.year.to_s[2..].to_i..18)}"
        filter_date_to = "#{year}-#{rand(1..12).to_s.rjust(2, '0')}-#{rand(1..28).to_s.rjust(2, '0')}"
        data = BitcoinDataParser.new(order_dir: :asc, filter_date_from: filter_date_from, filter_date_to: filter_date_to).parse

        first_date_not_less_than_filter_date = Date.parse(data.last.first) >= filter_date_from
        last_date_less_than_filter_date = Date.parse(data.last.first) <= Date.parse(filter_date_to)

        expect(first_date_not_less_than_filter_date).to be_truthy
        expect(last_date_less_than_filter_date).to be_truthy
      end

      it 'validate granularity weekly date' do
        data = BitcoinDataParser.new(granularity: :weekly).parse

        all_dates_is_monday = data.all? { |date, _price| Date.parse(date).monday? }

        expect(all_dates_is_monday).to be_truthy
      end

      it 'validate granularity weekly average price' do
        json = [
          {
            'date' => '2018-03-10', # Sut
            'price(USD)' => '9350.59'
          },
          {
            'date' => '2018-03-11', # Sun
            'price(USD)' => '8852.78'
          },
          {
            'date' => '2018-03-12', # Mon
            'price(USD)' => '9602.93'
          }
        ]
        data = BitcoinDataFilter.new(json, order_dir: :asc, granularity: :weekly).filter

        first_week_total_price = ((9350.59 + 8852.78) / 7).round(2)
        second_week_total_price = (9602.93 / 7).round(2)

        expect(data.first.last).to eq(first_week_total_price)
        expect(data.last.last).to eq(second_week_total_price)
      end

      it 'validate granularity monthly' do
        data = BitcoinDataParser.new(granularity: :monthly).parse

        all_dates_first_day_in_month = data.all? { |date, _price| Date.parse(date).day == 1 }

        expect(all_dates_first_day_in_month).to be_truthy
      end

      it 'validate granularity monthly average price' do
        json = [
          {
            'date' => '2018-03-10',
            'price(USD)' => '9350.59'
          },
          {
            'date' => '2018-03-11',
            'price(USD)' => '8852.78'
          },
          {
            'date' => '2018-03-12',
            'price(USD)' => '9602.93'
          },
          {
            'date' => '2018-02-25',
            'price(USD)' => '9796.42'
          }
        ]
        data = BitcoinDataFilter.new(json, granularity: :monthly).filter

        first_month_total_price = ((9350.59 + 8852.78 + 9602.93) / 31).round(2)
        second_month_total_price = (9796.42 / 28).round(2)

        expect(data.first.last).to eq(first_month_total_price)
        expect(data.last.last).to eq(second_month_total_price)
      end

      it 'validate granularity quarterly' do
        data = BitcoinDataParser.new(granularity: :quarterly).parse
        quarter_months = [1, 4, 7, 10]

        all_dates_first_day_in_quarter = data.all? do |date, _price|
          date = Date.parse(date)
          date.day == 1 && quarter_months.include?(date.month)
        end

        expect(all_dates_first_day_in_quarter).to be_truthy
      end

      it 'validate granularity quarterly average price' do
        json = [
          {
            'date' => '2018-07-07"',
            'price(USD)' => '6668.71'
          },
          {
            'date' => '2018-07-09',
            'price(USD)' => '6775.08'
          },
          {
            'date' => '2018-09-06',
            'price(USD)' => '6755.14'
          },
          {
            'date' => '2018-02-25',
            'price(USD)' => '9796.42'
          },
          {
            'date' => '2018-02-26',
            'price(USD)' => '9669.43'
          },
          {
            'date' => '2018-10-17',
            'price(USD)' => '6590.52'
          }
        ]
        data = BitcoinDataFilter.new(json, order_dir: :asc, granularity: :quarterly).filter

        first_quarter_total_price = ((9796.42 + 9669.43) / (31 + 28 + 31)).round(2)
        third_quarter_total_price = ((6668.71 + 6775.08 + 6755.14) / (31 + 31 + 30)).round(2)
        fourth_quarter_total_price = (6590.52 / (31 + 30 + 31)).round(2)

        expect(data[0].last).to eq(first_quarter_total_price)
        expect(data[1].last).to eq(third_quarter_total_price)
        expect(data[2].last).to eq(fourth_quarter_total_price)
      end

      it 'fail if invalid filter' do
        expect {
          BitcoinDataParser.new(order: :asc).parse
        }.to raise_error(BitcoinDataFilter::InvalidFilterError, 'Filters must be from the list: order_dir, filter_date_from, filter_date_to or granularity')
      end

      it 'fail if invalid granularity filter' do
        expect {
          BitcoinDataParser.new(granularity: :yearly).parse
        }.to raise_error(BitcoinDataFilter::InvalidGranularityFilterError, 'Granularity must be daily, weekly, monthly or quarterly')
      end
    end
  end
end
