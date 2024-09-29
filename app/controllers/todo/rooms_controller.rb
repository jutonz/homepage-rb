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

    def show
      @room = find_room
    end

    def edit
      @room = find_room
    end

    def update
      @room = find_room

      if @room.update(room_params)
        redirect_to(todo_room_path(@room), notice: "Updated room")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      find_room.destroy
      redirect_to(todo_rooms_path, notice: "Deleted room")
    end

    private

    def room_params
      params.require(:todo_room).permit(:name)
    end

    def find_room
      current_user.todo_rooms.find(params[:id])
    end
  end
end
