require 'rails_helper'
require_dependency 'site_setting'
require_dependency 'site_setting_extension'

describe SiteSetting do

  describe 'topic_title_length' do
    it 'returns a range of min/max topic title length' do
      expect(SiteSetting.topic_title_length).to eq(
        (SiteSetting.defaults[:min_topic_title_length]..SiteSetting.defaults[:max_topic_title_length])
      )
    end
  end

  describe 'post_length' do
    it 'returns a range of min/max post length' do
      expect(SiteSetting.post_length).to eq(SiteSetting.defaults[:min_post_length]..SiteSetting.defaults[:max_post_length])
    end
  end

  describe 'first_post_length' do
    it 'returns a range of min/max first post length' do
      expect(SiteSetting.first_post_length).to eq(SiteSetting.defaults[:min_first_post_length]..SiteSetting.defaults[:max_post_length])
    end
  end

  describe 'private_message_title_length' do
    it 'returns a range of min/max pm topic title length' do
      expect(SiteSetting.private_message_title_length).to eq(SiteSetting.defaults[:min_private_message_title_length]..SiteSetting.defaults[:max_topic_title_length])
    end
  end

  describe 'in test we do some judo to ensure SiteSetting is always reset between tests' do

    it 'is always the correct default' do
      expect(SiteSetting.contact_email).to eq('')
    end

    it 'sets a setting' do
      SiteSetting.contact_email = 'sam@sam.com'
    end

    it 'is always the correct default' do
      expect(SiteSetting.contact_email).to eq('')
    end
  end

  describe "anonymous_homepage" do
    it "returns latest" do
      expect(SiteSetting.anonymous_homepage).to eq('latest')
    end
  end

  describe "top_menu" do
    before { SiteSetting.top_menu = 'one,-nope|two|three,-not|four,ignored|category/xyz|latest' }

    describe "items" do
      let(:items) { SiteSetting.top_menu_items }

      it 'returns TopMenuItem objects' do
        expect(items[0]).to be_kind_of(TopMenuItem)
      end
    end

    describe "homepage" do
      it "has homepage" do
        expect(SiteSetting.homepage).to eq('one')
      end
    end
  end

  describe "min_redirected_to_top_period" do

    context "has_enough_top_topics" do

      before do
        SiteSetting.topics_per_period_in_top_page = 2
        SiteSetting.top_page_default_timeframe = 'daily'

        2.times do
          TopTopic.create!(daily_score: 2.5)
        end

        TopTopic.refresh!
      end

      it "should_return_a_time_period" do
        expect(SiteSetting.min_redirected_to_top_period(1.days.ago)).to eq(:daily)
      end

    end

    context "does_not_have_enough_top_topics" do

      before do
        SiteSetting.topics_per_period_in_top_page = 20
        SiteSetting.top_page_default_timeframe = 'daily'
        TopTopic.refresh!
      end

      it "should_return_a_time_period" do
        expect(SiteSetting.min_redirected_to_top_period(1.days.ago)).to eq(nil)
      end

    end

  end

  describe "scheme" do
    before do
      SiteSetting.force_https = true
    end


    it "returns http when ssl is disabled" do
      SiteSetting.force_https = false
      expect(SiteSetting.scheme).to eq("http")
    end

    it "returns https when using ssl" do
      expect(SiteSetting.scheme).to eq("https")
    end

  end

  context 'deprecated site settings' do
    before do
      SiteSetting.force_https = true
    end

    after do
      SiteSetting.force_https = false
    end

    describe '#use_https' do
      it 'should act as a proxy to the new methods' do
        expect(SiteSetting.use_https).to eq(true)
        expect(SiteSetting.use_https?).to eq(true)

        SiteSetting.use_https = false

        expect(SiteSetting.force_https).to eq(false)
        expect(SiteSetting.force_https?).to eq(false)
      end
    end
  end
end
