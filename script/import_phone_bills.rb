#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"

# Script to import phone bills from bills.csv into a SharedBill
# Usage: USER_ID=<id> bundle exec rails runner script/import_phone_bills.rb

class PhoneBillImporter
  SHARED_BILL_NAME = "Phone Bill"
  CSV_FILE_PATH = "/tmp/bills.csv"
  PAYEE_NAMES = ["Carolyn", "Justin"]

  def initialize(user_id:)
    @user_id = user_id
    @user = User.find(user_id)
  end

  def import
    puts "Starting Phone Bill import for user #{@user.id}..."

    ActiveRecord::Base.transaction do
      create_shared_bill
      create_payees
      import_bills
    end

    puts "\n✓ Import completed successfully!"
    puts "  - Created SharedBill: #{@shared_bill.name}"
    puts "  - Created #{@payees.count} payees"
    puts "  - Imported #{@bill_count} bills"
  rescue ActiveRecord::RecordNotFound => e
    puts "✗ Error: #{e.message}"
    exit(1)
  rescue => e
    puts "✗ Import failed: #{e.message}"
    puts e.backtrace.first(5).join("\n")
    exit(1)
  end

  private

  def create_shared_bill
    @shared_bill = SharedBills::SharedBill.create!(
      user: @user,
      name: SHARED_BILL_NAME
    )
    puts "Created SharedBill: #{@shared_bill.name}"
  end

  def create_payees
    @payees = {}
    PAYEE_NAMES.each do |name|
      payee = SharedBills::Payee.create!(
        shared_bill: @shared_bill,
        name: name
      )
      @payees[name] = payee
      puts "Created Payee: #{name}"
    end
  end

  def import_bills
    @bill_count = 0
    csv_path = CSV_FILE_PATH

    unless File.exist?(csv_path)
      raise "CSV file not found at #{csv_path}"
    end

    CSV.foreach(csv_path, headers: true) do |row|
      next if row["Period start"].blank?

      import_bill(row)
      @bill_count += 1
      print "."
    end

    puts "\nImported #{@bill_count} bills"
  end

  def import_bill(row)
    period_start = parse_date(row["Period start"])
    period_end = parse_date(row["Period end"])

    # Handle year rollover (e.g., Dec 2021 to Jan 2022)
    if period_end <= period_start
      period_end = period_end.next_year
    end

    carolyn_amount = parse_amount(row["Carolyn amount"])
    justin_amount = parse_amount(row["Justin amount"])
    paid = parse_paid(row["Paid"])

    bill = SharedBills::Bill.create!(
      shared_bill: @shared_bill,
      period_start: period_start,
      period_end: period_end
    )

    SharedBills::PayeeBill.create!(
      bill: bill,
      payee: @payees["Carolyn"],
      amount_cents: carolyn_amount,
      paid: paid
    )

    SharedBills::PayeeBill.create!(
      bill: bill,
      payee: @payees["Justin"],
      amount_cents: justin_amount,
      paid: paid
    )
  end

  def parse_date(date_string)
    # Parse dates like "2021 May 7" or "2021 Jun 7"
    Date.parse(date_string)
  end

  def parse_amount(amount_string)
    # Convert "$49.17" to 4917 cents
    (amount_string.gsub(/[$,]/, "").to_f * 100).round
  end

  def parse_paid(paid_string)
    paid_string&.strip&.downcase == "yes"
  end
end

# Main execution
user_id = ENV["USER_ID"]

if user_id.blank?
  puts "Error: USER_ID environment variable is required"
  puts "Usage: USER_ID=<id> bundle exec rails runner script/import_phone_bills.rb"
  exit(1)
end

PhoneBillImporter.new(user_id: user_id).import
