# typed: strict

class IssuesController < ApplicationController
  before_action :ensure_authenticated!
  after_action :verify_authorized

  sig { void }
  def new
    @projects = T.let(user_projects, T.nilable(ActiveRecord::Relation))
    @project = T.let(
      user_projects.find_by(id: params[:project_id]),
      T.nilable(Issues::Project)
    )
    @issue = T.let(
      authorize(current_user.issues.new(project: @project)),
      T.nilable(Issue)
    )
  end

  sig { void }
  def create
    @issue = authorize(T.let(current_user.issues.new(issue_params), Issue))
    @projects = T.let(user_projects, T.nilable(ActiveRecord::Relation))

    if @issue.save
      redirect_to(
        issue_path(@issue),
        notice: "Issue was successfully created."
      )
    else
      render(:new, status: :unprocessable_content)
    end
  end

  sig { void }
  def show
    @issue = authorize(find_issue)
  end

  sig { void }
  def edit
    @issue = authorize(find_issue)
    @project = T.let(@issue.project, T.nilable(Issues::Project))
    @projects = T.let(user_projects, T.nilable(ActiveRecord::Relation))
  end

  sig { void }
  def update
    @issue = authorize(find_issue)
    @project = T.let(@issue.project, T.nilable(Issues::Project))
    @projects = T.let(user_projects, T.nilable(ActiveRecord::Relation))

    if @issue.update(issue_params)
      redirect_to(
        issue_path(@issue),
        notice: "Issue was successfully updated."
      )
    else
      render(:edit, status: :unprocessable_content)
    end
  end

  sig { void }
  def destroy
    issue = authorize(find_issue)
    issue.destroy!

    redirect_to(
      project_path(issue.project),
      status: :see_other,
      notice: "Issue was successfully deleted."
    )
  end

  private

  sig { returns(Issue) }
  def find_issue
    IssuePolicy.scope_for(current_user).find(params[:id])
  end

  sig { returns(ActiveRecord::Relation) }
  def user_projects
    Issues::ProjectPolicy.scope_for(current_user).order(:name)
  end

  sig { returns(ActionController::Parameters) }
  def issue_params
    params.expect(
      issue: %i[title status description project_id pr_url]
    )
  end
end
