require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:comment) { FactoryBot.build(:comment) }

  it "respond to content" do
    expect(comment).to respond_to(:content)
  end
end
