require "rails_helper"

RSpec.describe SharedBillsController do
  describe "#index" do
    it "if not logged in, redirects" do
      get(shared_bills_path)
      expect(response).to redirect_to(new_session_path)
      expect(session[:return_to]).to eql(shared_bills_path)
    end

    it "shows shared bills when logged in" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      login_as(user)

      get(shared_bills_path)

      expect(response).to be_successful
      expect(response.body).to include(shared_bill.name)
    end

    it "does not show other users' shared bills" do
      user = create(:user)
      other_user = create(:user)
      create(:shared_bill, user: other_user, name: "Other Bill")
      login_as(user)

      get(shared_bills_path)

      expect(response).to be_successful
      expect(response.body).not_to include("Other Bill")
    end
  end

  describe "#show" do
    it "displays bills with total amounts and unpaid status" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = create(:shared_bills_bill, shared_bill:)
      create(:shared_bills_payee_bill, :unpaid, bill:, amount_cents: 1000)
      create(:shared_bills_payee_bill, :unpaid, bill:, amount_cents: 500)
      login_as(user)

      get(shared_bill_path(shared_bill))

      expect(response).to be_successful
      expect(page.text).to include("$15.00")
      expect(page.text).to include("Unpaid")
    end

    it "displays paid status when all payees have paid" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = create(:shared_bills_bill, shared_bill:)
      create(:shared_bills_payee_bill, :paid, bill:)
      create(:shared_bills_payee_bill, :paid, bill:)
      login_as(user)

      get(shared_bill_path(shared_bill))

      expect(response).to be_successful
      expect(page.text).to include("Paid")
    end

    it "displays unpaid status when some payees haven't paid" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = create(:shared_bills_bill, shared_bill:)
      create(:shared_bills_payee_bill, :paid, bill:)
      create(:shared_bills_payee_bill, :unpaid, bill:)
      login_as(user)

      get(shared_bill_path(shared_bill))

      expect(response).to be_successful
      expect(page.text).to include("Unpaid")
    end

    it "displays $0.00 and unpaid for bills with no payee_bills" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      create(:shared_bills_bill, shared_bill:)
      login_as(user)

      get(shared_bill_path(shared_bill))

      expect(response).to be_successful
      expect(page.text).to include("$0.00")
      expect(page.text).to include("Unpaid")
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      other_user = create(:user)
      login_as(other_user)

      get(shared_bill_path(shared_bill))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)

      get(shared_bill_path(shared_bill))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#create" do
    it "creates a shared bill" do
      user = create(:user)
      params = {
        shared_bill: {
          name: "hello"
        }
      }
      login_as(user)

      post(shared_bills_path, params:)

      expect(response).to have_http_status(:found)
      shared_bill = SharedBills::SharedBill.last
      expect(response).to redirect_to(shared_bill_path(shared_bill))
    end

    it "renders validation errors" do
      user = create(:user)
      params = {
        shared_bill: {
          name: ""
        }
      }
      login_as(user)

      post(shared_bills_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page.text).to include("can't be blank")
    end
  end
end
