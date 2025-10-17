module SharedBills
  class PayeesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def new
      @shared_bill = find_shared_bill
      @payee = authorize(@shared_bill.payees.new)
    end

    def edit
      @shared_bill = find_shared_bill
      @payee = authorize(find_payee)
    end

    def create
      @shared_bill = find_shared_bill
      @payee = @shared_bill.payees
        .new(payee_params)
        .then { authorize(it) }

      if @payee.save
        redirect_to(
          shared_bill_path(@shared_bill),
          notice: "Payee #{@payee.name} was added."
        )
      else
        render(:new, status: :unprocessable_content)
      end
    end

    def update
      @shared_bill = find_shared_bill
      @payee = authorize(find_payee)

      if @payee.update(payee_params)
        redirect_to(
          shared_bill_path(@shared_bill),
          notice: "Payee #{@payee.name} was updated."
        )
      else
        render(:edit, status: :unprocessable_content)
      end
    end

    def destroy
      @shared_bill = find_shared_bill
      @payee = authorize(find_payee)

      @payee.destroy!

      redirect_to(
        shared_bill_path(@shared_bill),
        status: :see_other,
        notice: "Payee #{@payee.name} has been removed."
      )
    end

    private

    def find_shared_bill
      policy_scope(SharedBills::SharedBill)
        .find(params[:shared_bill_id])
    end

    def find_payee
      @shared_bill.payees.find(params[:id])
    end

    def payee_params
      params.expect(payee: [:name])
    end
  end
end
