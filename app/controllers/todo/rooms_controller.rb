module Todo
  class RoomsController < ApplicationController
    before_action :ensure_authenticated!

    def index
      @rooms = current_user.todo_rooms
    end

    def new
      @room = Room.new
    end

    def create
      @room = current_user.todo_rooms.new(room_params)

      if @room.save
        redirect_to(todo_rooms_path, notice: "Created room")
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def room_params
      params.require(:todo_room).permit(:name)
    end
  end
end
