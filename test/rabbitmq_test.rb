require_relative 'test_helper'

class RabbitmqGaugeTest < MiniTest::Unit::TestCase
  attr_accessor :url, :gauge

  def setup
    super
    @url = 'http://foo.com:517672/api/exchanges/some_vhost'
    @gauge = Harness::RabbitmqGauge.new url

    stub_request(:get, url).to_return({
      status: 200,
      body: File.read(File.expand_path('../fixture.json', __FILE__))
    })
  end

  def test_records_total_confirmed
    log
    assert_gauge 'rabbitmq.dummy.confirmed.count'
  end

  def test_records_confirmation_rate
    log
    assert_gauge 'rabbitmq.dummy.confirmed.rate'
  end

  def test_records_total_published
    log
    assert_gauge 'rabbitmq.dummy.published.count'
  end

  def test_records_publish_rate
    log
    assert_gauge 'rabbitmq.dummy.published.rate'
  end

  def test_records_total_consumed
    log
    assert_gauge 'rabbitmq.dummy.consumed.count'
  end

  def test_records_consumption_rate
    log
    assert_gauge 'rabbitmq.dummy.consumed.rate'
  end

  def test_blows_up_if_server_does_not_return_a_200
    assert_raises Harness::RabbitmqGauge::BadResponseError do
      stub_request(:get, 'http://bad.host').to_return({
        status: 400,
        body: File.read(File.expand_path('../fixture.json', __FILE__))
      })
      Harness::RabbitmqGauge.new('http://bad.host').log
    end
  end

  private
  def log
    gauge.log
  end
end
