# typed: strict

module Issues
  class ProjectsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    PER_PAGE = 20

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
      @issues = T.let(
        IssuePolicy.scope_for(current_user)
          .where(project: @project)
          .order(created_at: :desc)
          .page(params[:page])
          .per(PER_PAGE),
        T.nilable(T.all(ActiveRecord::Relation, T::Enumerable[Issue]))
      )
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

      if project.destroy
        redirect_to(
          projects_path,
          status: :see_other,
          notice: "Project was successfully deleted."
        )
      else
        redirect_to(
          project_path(project),
          status: :see_other,
          alert: issues_remain_alert(project)
        )
      end
    end

    private

    sig { returns(Issues::Project) }
    def find_project
      Issues::ProjectPolicy.scope_for(current_user).find(params[:id])
    end

    sig { params(project: Issues::Project).returns(String) }
    def issues_remain_alert(project)
      issue_count = helpers.pluralize(project.issues.count, "issue")
      "Project still has #{issue_count}. Move or delete them first."
    end

    sig { returns(ActionController::Parameters) }
    def project_params
      params.expect(project: %i[name key])
    end
  end
end
