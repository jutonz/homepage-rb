module Todo
  class RoomsController < ApplicationController
    def index
      @rooms = Room.all
    end

    def new
      @room = Room.new
    end

    def create
      @room = Room.new(room_params)

      if @room.save
        redirect_to(
          todo_rooms_path,
          notice: "Created room"
        )
      else
        render :new
      end
    end

    private

    def room_params
      params.require(:room).permit(:name)
    end
  end
end
