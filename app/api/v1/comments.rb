module V1

  class Comments < Grape::API
    format :json
    rescue_from ActiveRecord::RecordNotFound do |e|
      error!({
               message: "#{e.message}",
             }, 404)
    end

    helpers do
      def current_user
        @current_user ||= User.find_by(auth_token: request.headers["Authorization"])
      end

      def authenticate_user_token!
        unless user_signed_in?
          error!({
                   message: "Unauthorized",
                 }, 401)
        end
      end

      def user_signed_in?
        current_user.present?
      end
    end

    before do
      authenticate_user_token!
    end

    resource :comments do
      desc 'Get all comments'
      get do
        Comment.all
      end

      desc 'Get a specific comment'
      params do
        requires :id, type: Integer, desc: 'Comment ID'
      end
      get ':id' do
        Comment.find(params[:id])
      end

      desc 'Create a new comment'
      params do
        requires :content, type: String, desc: 'Comment content'
      end
      post do
        Comment.create(content: params[:content])
      end

      desc 'Update a comment'
      params do
        requires :id, type: Integer, desc: 'Comment ID'
        requires :content, type: String, desc: 'New comment content'
      end
      put ':id' do
        comment = Comment.find(params[:id])
        authorize @comment
        comment.update(content: params[:content])
        comment
      end

      desc 'Delete a comment'
      params do
        requires :id, type: Integer, desc: 'Comment ID'
      end
      delete ':id' do
        comment = Comment.find(params[:id])
        authorize @comment
        comment.destroy
      end
    end

  end
end
