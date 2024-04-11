require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :controller do
  let(:parse_response) { JSON.parse(response.body) }
  let(:path) { "/api/v1/posts" }
  let(:not_found_post) { "not_found_post" }
  let(:user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :user, :admin }
  let(:headers) { { 'Authorization': user.auth_token } }
  let(:invalid_headers) { { 'Authorization': 'Invalid token' } }

  describe "GET /index", type: :request do
    before do
      @posts = FactoryBot.create_list :post, 3
    end
    context "when the user is authenticated" do
      context "when the user is admin" do
        it "returns all posts" do
          get path, headers: { 'Authorization': admin.auth_token }, as: :json
          expect(response).to have_http_status(:ok)
          expect(parse_response['data'].size).to eq 3
          expect(parse_response['success']).to eq true
        end
      end

      context "when the user is not admin" do
        it "returns published posts" do
          get path, headers: headers, as: :json
          expect(response).to have_http_status(:ok)
          expect(parse_response['data'].size).to eq 0
          expect(parse_response['success']).to eq true
        end
      end
    end

    context "when the user is not authenticated" do
      it "returns a forbidden response" do
        get path, headers: invalid_headers, as: :json
        expect(response).to have_http_status :forbidden
        expect(parse_response['error']).to eq 'Permission denied'
        expect(parse_response['success']).to eq false
      end
    end

  end

  describe "GET /show", type: :request do
    context "when the user is authenticated" do
      it "returns the requested post" do
        @post = FactoryBot.create :post, published: false
        get "#{path}/#{@post[:id]}", headers: { 'Authorization': admin.auth_token }, as: :json
        expect(response).to have_http_status(:ok)
        expect(parse_response['data']['id']).to eq @post[:id]
        expect(parse_response['success']).to eq true
      end

      context "when the post is not found" do
        it "returns a not found response" do
          get "#{path}/#{not_found_post}", headers: headers, as: :json
          expect(response).to have_http_status :not_found
          expect(parse_response['error']).to eq 'Not found'
          expect(parse_response['success']).to eq false
        end
      end
    end

    context "when the user is not authenticated" do
      it "returns a forbidden response" do
        @post = FactoryBot.create :post, published: false
        get "#{path}/#{@post[:id]}", headers: invalid_headers, as: :json
        expect(response).to have_http_status :forbidden
        expect(parse_response['error']).to eq 'Permission denied'
        expect(parse_response['success']).to eq false
      end
    end

  end

  describe "POST /create", type: :request do
    context "when the user is not authenticated" do
      it "returns a forbidden response" do
        post path, headers: invalid_headers
        expect(response).to have_http_status :forbidden
        expect(parse_response['error']).to eq 'Permission denied'
        expect(parse_response['success']).to eq false
      end
    end

    context "when the user is authenticated" do
      context "with valid parameters" do
        before(:each) do
          @user = FactoryBot.create :user
          @post = FactoryBot.build(:post, user: @user)
          post path, params: { post: @post }, headers: headers, as: :json
        end
        it "created a new Post in database" do
          expect(Post.count).to eq 1
        end

        it "returns a JSON response with the new post" do
          expect(response).to have_http_status(:created)
          expect(parse_response['data']['title']).to eq @post[:title]
          expect(parse_response['success']).to eq true
        end
      end

      context "with invalid parameters" do
        before do
          @post = FactoryBot.build(:invalid_post)
          post path, params: { post: @post }, headers: headers, as: :json
        end

        it 'does not create a new Post in database' do
          expect(Post.count).to eq 0
        end

        it "returns a JSON response with errors for the new post" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(parse_response['success']).to eq false
          expect(parse_response['errors']).to eq "Bad request"
        end
      end
    end
  end

  describe "PUT /update", type: :request do
    context "when the user is not authenticated" do
      it "returns a forbidden response" do
        put "#{path}/#{not_found_post}", headers: invalid_headers
        expect(response).to have_http_status :forbidden
        expect(parse_response['error']).to eq 'Permission denied'
        expect(parse_response['success']).to eq false
      end
    end

    context "when the user is authenticated" do
      context "when the post is found" do
        before(:each) do
          @post = FactoryBot.create :post, user: user
          @attributes = @post.attributes
        end
        context "with valid parameters" do
          before(:each) do
            @attributes[:title] = "New title"
            put "#{path}/#{@post[:id]}", params: { post: @attributes }, headers: headers, as: :json
          end
          it "updates the requested post" do
            @post.reload
            expect(@post[:title]).to eq "New title"
          end

          it "returns a JSON response with the updated post" do
            expect(response).to have_http_status(:ok)
            expect(parse_response['data']['title']).to eq "New title"
            expect(parse_response['success']).to eq true
          end
        end

        context "with invalid parameters" do
          before(:each) do
            @attributes[:title] = nil
            put "#{path}/#{@post[:id]}", params: { post: @attributes }, headers: headers, as: :json
          end
          it "will not update the requested post" do
            @post.reload
            expect(@post[:title]).to eq @post[:title]
          end

          it "returns a JSON response with errors for the new post" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(parse_response['success']).to eq false
            expect(parse_response['errors']).to eq 'Bad request'
          end
        end
      end

      context "when the post is not found" do
        it "returns a not found response" do
          put "#{path}/#{not_found_post}", headers: headers
          expect(response).to have_http_status :not_found
          expect(parse_response['error']).to eq 'Not found'
          expect(parse_response['success']).to eq false
        end
      end
    end

  end

  describe "DELETE /destroy", type: :request do
    before(:each) do
      @post = FactoryBot.create :post, user: user
    end

    context "when the user is not authenticated" do
      it "returns a forbidden response" do
        delete "#{path}/#{@post[:id]}", headers: invalid_headers
        expect(response).to have_http_status :forbidden
        expect(parse_response['error']).to eq 'Permission denied'
        expect(parse_response['success']).to eq false
      end
    end

    context "when the user is authenticated" do
      context "when the post is found" do
        it "destroys the requested post" do
          delete "#{path}/#{@post[:id]}", headers: headers, as: :json
          expect(response).to have_http_status(:no_content)
          expect(Post.find_by(id: @post[:id])).to eq nil
        end
      end

      context "when the post is not found" do
        it "returns a not found response" do
          delete "#{path}/#{not_found_post}", headers: headers
          expect(response).to have_http_status :not_found
          expect(parse_response['error']).to eq 'Not found'
          expect(parse_response['success']).to eq false
        end
      end
    end

  end
end
