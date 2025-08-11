module Settings
  module Api
    class TokensController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized
      def index
        authorize ::Api::Token
        @tokens = policy_scope(::Api::Token)
      end

      def new
        @token = authorize(current_user.api_tokens.new)
      end

      def create
        @token = authorize(current_user.api_tokens.new(token_params))

        if @token.save
          redirect_to settings_api_token_path(@token), notice: "Created token"
        else
          render :new, status: :unprocessable_content
        end
      end

      def show
        @token = authorize(find_token)
      end

      def edit
        @token = authorize(find_token)
      end

      def update
        @token = authorize(find_token)

        if @token.update(token_params)
          redirect_to settings_api_token_path(@token), notice: "Updated token"
        else
          render :new, status: :unprocessable_content
        end
      end

      private

      def find_token
        policy_scope(::Api::Token).find(params[:id])
      end

      def token_params
        params.require(:api_token).permit(:name)
      end
    end
  end
end
