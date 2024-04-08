require 'rails_helper'

RSpec.describe PostPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:post) { FactoryBot.build(:post, user: user) }
  let(:another_post) { FactoryBot.build(:post, user: FactoryBot.build(:user, email: "somebody_else")) }
  subject { described_class }

  describe "scope" do
    let(:posts) { FactoryBot.create_list(:post, 3) }
    let(:published_post) { FactoryBot.create(:post, published: true) }
    describe '.only admin can see unpublished posts' do
      it 'returns all posts for admin' do
        expect(PostPolicy::Scope.new(admin, Post.all).resolve).to eq(Post.all)
      end

      it 'returns only published posts for non-admin' do
        expect(PostPolicy::Scope.new(user, Post.all).resolve).to eq([published_post])
      end
    end
  end

  permissions :update? do
    context "when user is the owner of the post" do
      it "allows user to update the post" do
        expect(subject).to permit(user, post)
      end
    end

    context "when user is not the owner of the post" do
      it "does not allow user to update the post" do
        expect(subject).not_to permit(user, another_post)
      end
    end
  end

  permissions :destroy? do
    context "when user is the owner of the post" do
      it "allows user to delete the post" do
        expect(subject).to permit(user, post)
      end
    end

    context "when user is not the owner of the post" do
      it "does not allow user to delete the post" do
        expect(subject).not_to permit(user, another_post)
      end
    end
  end
end
