require 'rails_helper'
RSpec.describe PublishPostJob, type: :job do
  let(:post) { FactoryBot.create(:post) }
  let(:post_id) { post.id }
  describe 'PublishPostJob#perform_in' do

    before(:each) do
      PublishPostJob.perform_in(1.hour, post_id)
    end

    it "should enqueue the job on time" do
      time = 1.hour.from_now
      expect(PublishPostJob).to be_processed_in :default
      expect(PublishPostJob).to have_enqueued_sidekiq_job(post_id).at(time)
    end

    it "should retry 3 times" do
      expect(PublishPostJob).to be_retryable 3
    end

  end

  describe "#perform" do
    before(:each) do
      described_class.new.perform(post_id)
      post.reload
    end

    context "When post id is valid" do
      it "published the post" do
        expect(post.published).to be_truthy
      end
    end

    context "when post id is not valid" do
      let(:post_id) { SecureRandom.uuid }
      it "should not publish the post" do
        expect(post.published).to be_falsey
      end
    end

  end
end
