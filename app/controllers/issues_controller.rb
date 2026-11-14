# typed: strict

class IssuesController < ApplicationController
  before_action :ensure_authenticated!
  after_action :verify_authorized

  PER_PAGE = 20

  sig { void }
  def index
    authorize(Issue)
    @issues = T.let(
      IssuePolicy.scope_for(current_user)
        .order(created_at: :desc)
        .page(params[:page])
        .per(PER_PAGE),
      T.nilable(T.all(ActiveRecord::Relation, T::Enumerable[Issue]))
    )
  end

  sig { void }
  def new
    @issue = T.let(authorize(current_user.issues.new), T.nilable(Issue))
  end

  sig { void }
  def create
    @issue = authorize(T.let(current_user.issues.new(issue_params), Issue))

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
  end

  sig { void }
  def update
    @issue = authorize(find_issue)

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
      issues_path,
      status: :see_other,
      notice: "Issue was successfully deleted."
    )
  end

  private

  sig { returns(Issue) }
  def find_issue
    IssuePolicy.scope_for(current_user).find(params[:id])
  end

  sig { returns(ActionController::Parameters) }
  def issue_params
    params.expect(issue: %i[title status description])
  end
end
