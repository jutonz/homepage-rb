# typed: strict

module Issues
  class ProjectsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def index
      authorize(Issues::Project)
      @projects = T.let(
        Issues::ProjectPolicy.scope_for(current_user).order(:name),
        T.nilable(
          T.all(ActiveRecord::Relation, T::Enumerable[Issues::Project])
        )
      )
    end

    sig { void }
    def new
      @project = T.let(
        authorize(current_user.issues_projects.new),
        T.nilable(Issues::Project)
      )
    end

    sig { void }
    def create
      @project = authorize(
        T.let(current_user.issues_projects.new(project_params), Issues::Project)
      )

      if @project.save
        redirect_to(
          project_path(@project),
          notice: "Project was successfully created."
        )
      else
        render(:new, status: :unprocessable_content)
      end
    end

    sig { void }
    def show
      @project = authorize(find_project)
    end

    sig { void }
    def edit
      @project = authorize(find_project)
    end

    sig { void }
    def update
      @project = authorize(find_project)

      if @project.update(project_params)
        redirect_to(
          project_path(@project),
          notice: "Project was successfully updated."
        )
      else
        render(:edit, status: :unprocessable_content)
      end
    end

    sig { void }
    def destroy
      project = authorize(find_project)
      project.destroy!

      redirect_to(
        projects_path,
        status: :see_other,
        notice: "Project was successfully deleted."
      )
    end

    private

    sig { returns(Issues::Project) }
    def find_project
      Issues::ProjectPolicy.scope_for(current_user).find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def project_params
      params.expect(project: %i[name key])
    end
  end
end
