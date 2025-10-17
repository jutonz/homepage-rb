module SharedBills
  class BillsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def show
      @shared_bill = find_shared_bill
      @bill = authorize(find_bill)
    end

    def new
      @shared_bill = find_shared_bill
      @bill = authorize(@shared_bill.bills.new)
    end

    def edit
      @shared_bill = find_shared_bill
      @bill = authorize(find_bill)
    end

    def create
      @shared_bill = find_shared_bill
      @bill = @shared_bill.bills
        .new(bill_params)
        .then { authorize(it) }

      if @bill.save
        redirect_to(
          shared_bill_path(@shared_bill),
          notice: "Bill #{@bill.name} was added."
        )
      else
        render(:new, status: :unprocessable_content)
      end
    end

    def update
      @shared_bill = find_shared_bill
      @bill = authorize(find_bill)

      if @bill.update(bill_params)
        redirect_to(
          shared_bill_path(@shared_bill),
          notice: "Bill #{@bill.name} was updated."
        )
      else
        render(:edit, status: :unprocessable_content)
      end
    end

    def destroy
      @shared_bill = find_shared_bill
      @bill = authorize(find_bill)

      @bill.destroy!

      redirect_to(
        shared_bill_path(@shared_bill),
        status: :see_other,
        notice: "Bill #{@bill.name} has been removed."
      )
    end

    private

    def find_shared_bill
      policy_scope(SharedBills::SharedBill)
        .find(params[:shared_bill_id])
    end

    def find_bill
      @shared_bill.bills.find(params[:id])
    end

    def bill_params
      params.expect(bill: [:name])
    end
  end
end
