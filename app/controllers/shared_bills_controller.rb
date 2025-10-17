class SharedBillsController < ApplicationController
  before_action :ensure_authenticated!
  after_action :verify_authorized

  def index
    authorize(SharedBills::SharedBill)
    @shared_bills =
      policy_scope(SharedBills::SharedBill)
        .order(created_at: :desc)
  end

  def show
    @shared_bill = authorize(find_shared_bill)
  end

  def new
    @shared_bill = authorize(current_user.shared_bills.new)
  end

  def edit
    @shared_bill = authorize(find_shared_bill)
  end

  def create
    @shared_bill =
      current_user.shared_bills
        .new(shared_bill_params)
        .then { authorize(it) }

    if @shared_bill.save
      redirect_to(
        shared_bill_path(@shared_bill),
        notice: "Shared bill was successfully created."
      )
    else
      render(:new, status: :unprocessable_content)
    end
  end

  def update
    @shared_bill = authorize(find_shared_bill)

    if @shared_bill.update(shared_bill_params)
      redirect_to(
        shared_bill_path(@shared_bill),
        notice: "Shared bill was successfully updated."
      )
    else
      render(:edit, status: :unprocessable_content)
    end
  end

  def destroy
    @shared_bill = authorize(find_shared_bill)
    @shared_bill.destroy!

    redirect_to(
      shared_bills_path,
      status: :see_other,
      notice: "Shared bill was successfully destroyed."
    )
  end

  private

  def find_shared_bill
    policy_scope(SharedBills::SharedBill).find(params[:id])
  end

  def shared_bill_params
    params.expect(shared_bill: [:name])
  end
end
