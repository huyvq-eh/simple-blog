require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "it respond to the following methods" do
    before(:each) do
      @user = FactoryBot.create(:user)
      @post = FactoryBot.build(:post, user: @user)
      @nil_post = FactoryBot.build(:invalid_post)
    end

    it "respond to title" do
      expect(@post).to respond_to(:title)
    end

    it "respond to content" do
      expect(@post).to respond_to(:content)
    end

    it "respond to published" do
      expect(@post).to respond_to(:published)
    end

    it "respond to user" do
      expect(@post).to respond_to(:user_id)
    end

    it "corresponds to a correct user" do
      expect(@post.user.email).to eq @user.email
    end

    it "validates presence of attributes in post" do
      expect(@nil_post).to be_invalid
      expect(@nil_post.errors.messages[:title]).to include("can't be blank")
      expect(@nil_post.errors.messages[:content]).to include("can't be blank")
    end

    it "delete all comments when post is deleted" do
      FactoryBot.create_list(:comment, 2, post: @post, user: @user)
      @post.destroy
      expect(Comment.count).to eq 0
    end

    it "always has the content" do
      @post.content = nil
      expect(@post).to be_invalid
      expect(@post.errors.messages[:content]).to include("can't be blank")
    end
  end
end
