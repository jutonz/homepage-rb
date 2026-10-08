# typed: strict

class UserSeedJob < ApplicationJob
  sig { returns(T.nilable(User)) }
  attr_reader :user

  sig { params(user: User).void }
  def perform(user)
    @user = T.let(user, T.nilable(User))
    seed_shared_bills
  end

  sig { void }
  def seed_shared_bills
    FactoryBot.create_pair(:shared_bill, user:).each do |shared_bill|
      payees = FactoryBot.create_pair(:shared_bills_payee, shared_bill:)

      Array(0..47).each do |month|
        bill = FactoryBot.create(
          :shared_bills_bill,
          shared_bill:,
          period_start: month.month.ago.beginning_of_month,
          period_end: month.months.ago.end_of_month
        )

        payees.each do |payee|
          FactoryBot.create(
            :shared_bills_payee_bill,
            payee:,
            bill:,
            amount_cents: 1000
          )
        end
      end
    end
  end
end
