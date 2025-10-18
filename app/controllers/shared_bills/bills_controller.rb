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
      @bill_form = SharedBills::BillForm.new(bill: @bill, shared_bill: @shared_bill)
    end

    def edit
      @shared_bill = find_shared_bill
      @bill = authorize(find_bill)
      @bill_form = SharedBills::BillForm.new(bill: @bill, shared_bill: @shared_bill)
    end

    def create
      @shared_bill = find_shared_bill
      @bill = authorize(@shared_bill.bills.new)
      @bill_form = SharedBills::BillForm.new(
        bill: @bill,
        shared_bill: @shared_bill
      )

      @bill_form.assign(bill_form_params)

      if @bill_form.save
        period = "#{@bill_form.period_start.to_date} - #{@bill_form.period_end.to_date}"
        redirect_to(
          shared_bill_path(@shared_bill),
          notice: "Bill for #{period} was added."
        )
      else
        render(:new, status: :unprocessable_content)
      end
    end

    def update
      @shared_bill = find_shared_bill
      @bill = authorize(find_bill)
      @bill_form = SharedBills::BillForm.new(
        bill: @bill,
        shared_bill: @shared_bill
      )

      @bill_form.assign(bill_form_params)

      if @bill_form.save
        period = "#{@bill_form.period_start.to_date} - #{@bill_form.period_end.to_date}"
        redirect_to(
          shared_bill_path(@shared_bill),
          notice: "Bill for #{period} was updated."
        )
      else
        render(:edit, status: :unprocessable_content)
      end
    end

    def destroy
      @shared_bill = find_shared_bill
      @bill = authorize(find_bill)

      @bill.destroy!

      period = "#{@bill.period_start.to_date} - #{@bill.period_end.to_date}"
      redirect_to(
        shared_bill_path(@shared_bill),
        status: :see_other,
        notice: "Bill for #{period} has been removed."
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

    def bill_form_params
      params.expect(bill_form: [:period_start, :period_end, payee_amounts: {}])
    end
  end
end
