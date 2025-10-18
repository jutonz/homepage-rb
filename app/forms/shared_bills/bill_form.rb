module SharedBills
  class BillForm
    include ActiveModel::Model

    attr_accessor :period_start, :period_end, :payee_amounts
    attr_reader :bill, :shared_bill

    def initialize(bill:, shared_bill:)
      @bill = bill
      @shared_bill = shared_bill
      @period_start = bill.period_start
      @period_end = bill.period_end

      # payee_amounts is a hash:
      # { payee_id => { selected: true/false, amount: int, paid: bool } }
      @payee_amounts = {}
      if bill.persisted?
        bill.payee_bills.each do |pb|
          @payee_amounts[pb.payee_id.to_s] = {
            selected: true,
            amount: pb.amount_cents,
            paid: pb.paid
          }
        end
      else
        # Default: all payees selected with blank amount, not paid
        shared_bill.payees.each do |payee|
          @payee_amounts[payee.id.to_s] = {
            selected: true,
            amount: nil,
            paid: false
          }
        end
      end
    end

    validate :payees_belong_to_shared_bill

    def assign(params)
      @period_start = params[:period_start]
      @period_end = params[:period_end]
      @payee_amounts = params.fetch(:payee_amounts, {})
    end

    def valid?(...)
      super.tap { merge_errors }
    end

    def save
      merge_errors and return false if invalid?

      bill.update!(
        period_start:,
        period_end:,
        payee_bills: build_payee_bills
      )

      true
    rescue ActiveRecord::RecordInvalid
      merge_errors
      false
    end

    def build_payee_bills
      @payee_amounts.to_h.filter_map do |payee_id, data|
        next unless is_selected(data)

        paid = data[:paid] || data["paid"]
        paid = paid == "1" || paid == true

        SharedBills::PayeeBill.new(
          bill:,
          payee_id:,
          amount_cents: data[:amount] || data["amount"],
          paid:
        )
      end
    end

    def merge_errors
      bill.errors.messages.each do |attr, message|
        errors.add(attr, message.join(", "))
      end

      bill.payee_bills.each do |payee_bill|
        payee_bill.errors.messages.each do |attr, message|
          errors.add(attr, message.join(", "))
        end
      end
    end

    def persisted? = bill.persisted?

    def to_key = bill.to_key

    def to_model = self

    def model_name
      ActiveModel::Name.new(self.class, nil, "Bill")
    end

    private

    def payees_belong_to_shared_bill
      allowed_payee_ids = shared_bill.payees.map { it.id.to_s }
      payee_amounts.keys.each do |payee_id|
        unless payee_id.in?(allowed_payee_ids)
          errors.add(:payee_id, "must belong to shared bill")
        end
      end
    end

    def is_selected(data)
      selected_value = data[:selected] || data["selected"]
      # Checkbox sends "1" for checked, nothing for unchecked
      # When explicitly set to false/0, treat as not selected
      return false if selected_value.nil?
      return false if selected_value == false
      return false if selected_value == "0"

      true
    end
  end
end
