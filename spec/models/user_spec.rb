require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }

  it "respond to email" do
    expect(user).to respond_to(:email)
  end

  it "respond to password" do
    expect(user).to respond_to(:password)
  end

  it "respond to password_confirmation" do
    expect(user).to respond_to(:password_confirmation)
  end

  it "respond to admin" do
    expect(user).to respond_to(:admin)
  end

  it "has a unique email" do
    save_user = FactoryBot.create(:user)
    user.email = save_user.email
    expect(user).to_not be_valid
  end

  it "destroy dependent posts" do
    posts = FactoryBot.create_list(:post, 3, user: user)
    user.post = posts
    user.destroy
    expect(Post.all).to be_empty
  end

  describe "user#generate_authentication_token" do
    before(:each) do
      @user = FactoryBot.build :user
    end

    subject { @user }

    context "when the token is not created" do
      it "generates a new unique token" do
        allow(Devise).to receive(:friendly_token).and_return("auniquetoken123")
        subject.generate_authentication_token!
        expect(subject.auth_token).to eq "auniquetoken123"
      end
    end

    context "when the token is existed" do
      it "generates another token" do
        existing_user = FactoryBot.create :user
        subject.generate_authentication_token!
        expect(subject.auth_token).not_to eq existing_user.auth_token
      end
    end
  end
end
