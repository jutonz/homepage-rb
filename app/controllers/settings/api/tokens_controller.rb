module Settings
  module Api
    class TokensController < ApplicationController
      def index
        @tokens = current_user.api_tokens
      end

      def new
        @token = current_user.api_tokens.new
      end

      def create
        @token = current_user.api_tokens.new(token_params)

        if @token.save
          redirect_to settings_api_token_path(@token), notice: "Created token"
        else
          render :new, status: :unprocessable_entity
        end
      end

      def show
        @token = find_token
      end

      def edit
        @token = find_token
      end

      def update
        @token = find_token

        if @token.update(token_params)
          redirect_to settings_api_token_path(@token), notice: "Updated token"
        else
          render :new, status: :unprocessable_entity
        end
      end

      private

      def find_token
        current_user.api_tokens.find(params[:id])
      end

      def token_params
        params.require(:api_token).permit(:name)
      end
    end
  end
end
