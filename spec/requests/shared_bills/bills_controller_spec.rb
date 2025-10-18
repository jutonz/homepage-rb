require "rails_helper"

RSpec.describe SharedBills::BillsController do
  describe "#show" do
    it "shows bill details" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = create(:shared_bills_bill, shared_bill:)
      login_as(user)

      get(shared_bill_bill_path(shared_bill, bill))

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
      bill = create(:shared_bills_bill, shared_bill:)
      other_user = create(:user)
      login_as(other_user)

      get(shared_bill_bill_path(shared_bill, bill))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      bill = create(:shared_bills_bill, shared_bill:)

      get(shared_bill_bill_path(shared_bill, bill))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#new" do
    it "shows new bill form with payees" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      create(:shared_bills_payee, shared_bill:, name: "Payee1")
      login_as(user)

      get(new_shared_bill_bill_path(shared_bill))

      expect(response).to be_successful
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Shared Bills", href: shared_bills_path)
      expect(page).to have_link(
        shared_bill.name,
        href: shared_bill_path(shared_bill)
      )
      expect(page.text).to include("Payee1")
    end

    it "shows new bill form without payees" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      login_as(user)

      get(new_shared_bill_bill_path(shared_bill))

      expect(response).to be_successful
      expect(page.text).to include("No payees yet")
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      other_user = create(:user)
      login_as(other_user)

      get(new_shared_bill_bill_path(shared_bill))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)

      get(new_shared_bill_bill_path(shared_bill))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#edit" do
    it "shows edit bill form" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = create(:shared_bills_bill, shared_bill:)
      login_as(user)

      get(edit_shared_bill_bill_path(shared_bill, bill))

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
      bill = create(:shared_bills_bill, shared_bill:)
      other_user = create(:user)
      login_as(other_user)

      get(edit_shared_bill_bill_path(shared_bill, bill))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      bill = create(:shared_bills_bill, shared_bill:)

      get(edit_shared_bill_bill_path(shared_bill, bill))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#create" do
    it "creates a bill and redirects to shared bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      params = {
        bill_form: {
          name: "January Bill",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }
      login_as(user)

      post(shared_bill_bills_path(shared_bill), params:)

      expect(response).to have_http_status(:found)
      bill = SharedBills::Bill.last
      expect(bill.name).to eql("January Bill")
      expect(bill.shared_bill).to eql(shared_bill)
      expect(bill.payee_bills.count).to eql(1)
      expect(bill.payee_bills.first.amount).to eql(1000)
      expect(response).to redirect_to(shared_bill_path(shared_bill))
    end

    it "renders validation errors for missing name" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      params = {
        bill_form: {
          name: "",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }
      login_as(user)

      post(shared_bill_bills_path(shared_bill), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page.text).to include("can't be blank")
    end

    it "renders validation errors when no payees selected" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      params = {
        bill_form: {
          name: "January Bill",
          payee_amounts: {
            payee.id.to_s => {selected: "0", amount: "1000"}
          }
        }
      }
      login_as(user)

      post(shared_bill_bills_path(shared_bill), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page.text).to include("must select at least one payee")
    end

    it "renders validation errors when selected payee has no amount" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:, name: "Payee1")
      params = {
        bill_form: {
          name: "January Bill",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: ""}
          }
        }
      }
      login_as(user)

      post(shared_bill_bills_path(shared_bill), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page.text).to include("Payee1 must have an amount")
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      other_user = create(:user)
      params = {
        bill_form: {
          name: "January Bill",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }
      login_as(other_user)

      post(shared_bill_bills_path(shared_bill), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      params = {
        bill_form: {
          name: "January Bill",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }

      post(shared_bill_bills_path(shared_bill), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#update" do
    it "updates a bill and redirects to shared bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = create(:shared_bills_bill, shared_bill:, name: "before")
      params = {
        bill_form: {
          name: "after",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }
      login_as(user)

      put(shared_bill_bill_path(shared_bill, bill), params:)

      expect(response).to redirect_to(shared_bill_path(shared_bill))
      expect(bill.reload.name).to eql("after")
      expect(bill.payee_bills.count).to eql(1)
    end

    it "renders validation errors" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = create(:shared_bills_bill, shared_bill:, name: "before")
      params = {
        bill_form: {
          name: "",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }
      login_as(user)

      put(shared_bill_bill_path(shared_bill, bill), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(bill.reload.name).to eql("before")
      expect(page.text).to include("can't be blank")
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = create(:shared_bills_bill, shared_bill:)
      other_user = create(:user)
      params = {
        bill_form: {
          name: "updated",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }
      login_as(other_user)

      put(shared_bill_bill_path(shared_bill, bill), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = create(:shared_bills_bill, shared_bill:)
      params = {
        bill_form: {
          name: "updated",
          payee_amounts: {
            payee.id.to_s => {selected: "1", amount: "1000"}
          }
        }
      }

      put(shared_bill_bill_path(shared_bill, bill), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#destroy" do
    it "destroys a bill and redirects to shared bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = create(:shared_bills_bill, shared_bill:, name: "January Bill")
      login_as(user)

      delete(shared_bill_bill_path(shared_bill, bill))

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(shared_bill_path(shared_bill))
      expect(SharedBills::Bill.exists?(bill.id)).to be(false)
    end

    it "returns 404 for shared bill not owned by current user" do
      shared_bill = create(:shared_bill)
      bill = create(:shared_bills_bill, shared_bill:)
      other_user = create(:user)
      login_as(other_user)

      delete(shared_bill_bill_path(shared_bill, bill))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      shared_bill = create(:shared_bill)
      bill = create(:shared_bills_bill, shared_bill:)

      delete(shared_bill_bill_path(shared_bill, bill))

      expect(response).to redirect_to(new_session_path)
    end
  end
end
