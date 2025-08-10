module Todo
  class RoomsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      authorize Todo::Room
      @rooms = policy_scope(Todo::Room)
    end

    def new
      @room = authorize(current_user.todo_rooms.new)
    end

    def create
      @room = authorize(current_user.todo_rooms.new(room_params))

      if @room.save
        redirect_to(todo_rooms_path, notice: "Created room")
      else
        render :new, status: :unprocessable_content
      end
    end

    def show
      @room = authorize(find_room(includes: [tasks: :task_occurrences]))
    end

    def edit
      @room = authorize(find_room)
    end

    def update
      @room = authorize(find_room)

      if @room.update(room_params)
        redirect_to(todo_room_path(@room), notice: "Updated room")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize(find_room).destroy
      redirect_to(todo_rooms_path, notice: "Deleted room")
    end

    private

    def room_params
      params.require(:todo_room).permit(:name)
    end

    def find_room(includes: [])
      query = policy_scope(Todo::Room)
      query = query.includes(includes) if includes.present?
      query.find(params[:id])
    end
  end
end
