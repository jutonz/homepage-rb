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

    validates :period_start, presence: true
    validates :period_end, presence: true
    validate :at_least_one_payee_selected
    validate :selected_payees_have_amounts

    def assign(params)
      @period_start = parse_datetime(params[:period_start])
      @period_end = parse_datetime(params[:period_end])
      @payee_amounts = params[:payee_amounts] || {}
    end

    def save
      return false if invalid?

      bill.period_start = period_start
      bill.period_end = period_end
      return false unless bill.save

      begin
        bill.transaction do
          # Destroy existing PayeeBills and create new ones
          bill.payee_bills.destroy_all
          payee_amounts.each do |payee_id, data|
            next unless is_selected(data)

            paid_value = data[:paid] || data["paid"]
            paid_value = paid_value == "1" || paid_value == true

            payee_bill = bill.payee_bills.new(
              payee_id:,
              amount_cents: data[:amount] || data["amount"],
              paid: paid_value
            )

            unless payee_bill.save
              payee_bill.errors.each do |error|
                errors.add(
                  :base,
                  "#{error.attribute}: #{error.message}"
                )
              end
              raise ActiveRecord::Rollback
            end
          end
        end
      rescue ActiveRecord::Rollback
        return false
      end

      true
    end

    def persisted? = bill.persisted?

    def to_key = bill.to_key

    def to_model = self

    def model_name
      ActiveModel::Name.new(self.class, nil, "Bill")
    end

    private

    def at_least_one_payee_selected
      selected = payee_amounts.values.any? do |data|
        is_selected(data)
      end
      unless selected
        errors.add(:base, "must select at least one payee")
      end
    end

    def selected_payees_have_amounts
      payee_amounts.each do |payee_id, data|
        next unless is_selected(data)

        amount_value = data[:amount] || data["amount"]
        if amount_value.blank?
          payee = shared_bill.payees.find(payee_id)
          errors.add(:base, "#{payee.name} must have an amount")
        elsif amount_value.to_i <= 0
          payee = shared_bill.payees.find(payee_id)
          errors.add(:base, "#{payee.name} amount must be greater than 0")
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

    def parse_datetime(value)
      return nil if value.blank?
      return value if value.is_a?(Time) || value.is_a?(DateTime)

      Time.zone.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
