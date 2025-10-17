require "rails_helper"

RSpec.describe SharedBills::PayeesController do
  describe "#new" do
    it "shows new payee form" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      login_as(user)

      get(new_shared_bill_payee_path(shared_bill))

      expect(response).to be_successful
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Shared Bills", href: shared_bills_path)
      expect(page).to have_link(
        shared_bill.name,
        href: shared_bill_path(shared_bill)
      )
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      other_user = create(:user)
      login_as(other_user)

      get(new_shared_bill_payee_path(shared_bill))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)

      get(new_shared_bill_payee_path(shared_bill))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#edit" do
    it "shows edit payee form" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      login_as(user)

      get(edit_shared_bill_payee_path(shared_bill, payee))

      expect(response).to be_successful
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Shared Bills", href: shared_bills_path)
      expect(page).to have_link(
        shared_bill.name,
        href: shared_bill_path(shared_bill)
      )
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      other_user = create(:user)
      login_as(other_user)

      get(edit_shared_bill_payee_path(shared_bill, payee))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)

      get(edit_shared_bill_payee_path(shared_bill, payee))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#create" do
    it "creates a payee and redirects to shared bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      params = {payee: {name: "Payee"}}
      login_as(user)

      post(shared_bill_payees_path(shared_bill), params:)

      expect(response).to have_http_status(:found)
      payee = SharedBills::Payee.last
      expect(payee.name).to eql("Payee")
      expect(payee.shared_bill).to eql(shared_bill)
      expect(response).to redirect_to(shared_bill_path(shared_bill))
    end

    it "renders validation errors" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      params = {payee: {name: ""}}
      login_as(user)

      post(shared_bill_payees_path(shared_bill), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page.text).to include("can't be blank")
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      other_user = create(:user)
      params = {payee: {name: "Payee"}}
      login_as(other_user)

      post(shared_bill_payees_path(shared_bill), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      params = {payee: {name: "Payee"}}

      post(shared_bill_payees_path(shared_bill), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#update" do
    it "updates a payee and redirects to shared bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:, name: "before")
      params = {payee: {name: "after"}}
      login_as(user)

      put(shared_bill_payee_path(shared_bill, payee), params:)

      expect(response).to redirect_to(shared_bill_path(shared_bill))
      expect(payee.reload.name).to eql("after")
    end

    it "renders validation errors" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:, name: "before")
      params = {payee: {name: ""}}
      login_as(user)

      put(shared_bill_payee_path(shared_bill, payee), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(payee.reload.name).to eql("before")
      expect(page.text).to include("can't be blank")
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      other_user = create(:user)
      params = {payee: {name: "updated"}}
      login_as(other_user)

      put(shared_bill_payee_path(shared_bill, payee), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      params = {payee: {name: "updated"}}

      put(shared_bill_payee_path(shared_bill, payee), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#destroy" do
    it "destroys a payee and redirects to shared bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:, name: "Justin")
      login_as(user)

      delete(shared_bill_payee_path(shared_bill, payee))

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(shared_bill_path(shared_bill))
      expect(SharedBills::Payee.exists?(payee.id)).to be(false)
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      other_user = create(:user)
      login_as(other_user)

      delete(shared_bill_payee_path(shared_bill, payee))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)

      delete(shared_bill_payee_path(shared_bill, payee))

      expect(response).to redirect_to(new_session_path)
    end
  end
end
