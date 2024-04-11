# frozen_string_literal: true

module API
  module V1
    class Api::V1::PostsController < ::ApplicationController
      before_action :authenticate_user_token!
      before_action :set_post, only: [:update, :destroy]

      # GET /posts
      def index
        @posts = policy_scope(Post)
        render json: { data: @posts, success: true }, status: :ok
      end

      # GET /posts/1
      def show
        @post = policy_scope(Post).find(params[:id])
        render json: { data: @post, success: true }, status: :ok
      end

      # POST /posts
      def create
        unless user_is_admin?(current_user.email)
          render json: { error: 'Permission denied', success: false }, status: :forbidden
          return
        end
        @post = current_user.post.new(post_params)
        if @post.save
          render json: { data: @post, success: true }, status: :created
        else
          render json: { errors: "Bad request", success: false }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /posts/1
      def update
        if @post.update(post_params)
          render json: { data: @post, success: true }, status: :ok
        else
          render json: { errors: "Bad request", success: false }, status: :unprocessable_entity
        end
      end

      # DELETE /posts/1
      def destroy
        @post.destroy
        render status: :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_post
        unless current_user
          render json: { error: 'Permission denied', success: false }, status: :forbidden
          return
        end
        @post = current_user.post.find(params[:id])
        authorize @post
      end

      # Only allow a list of trusted parameters through.
      def post_params
        params.require(:post).permit(:content, :title, :user_id)
      end

      def user_is_admin?(email)
        response = EhProtobuf::EmploymentHero::Client
                     .cached(valid_for: 5.minutes)
                     .check_user_is_admin_or_not(user_email: email)
        response.message.admin == true ? true : false
      end

    end
  end
end


