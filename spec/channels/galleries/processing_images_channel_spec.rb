require "rails_helper"

RSpec.describe Galleries::ProcessingImagesChannel do
  it "rejects when not authenticated" do
    stub_connection(current_user: nil)

    subscribe(gallery_id: 1)

    expect(subscription).to be_rejected
  end

  it "rejects for a non-owned gallery" do
    user = create(:user)
    gallery = create(:gallery)
    stub_connection(current_user: user)

    subscribe(gallery_id: gallery.id)

    expect(subscription).to be_rejected
  end

  it "streams for an owned gallery" do
    user = create(:user)
    gallery = create(:gallery, user:)
    stub_connection(current_user: user)

    subscribe(gallery_id: gallery.id)

    expect(subscription).to be_confirmed
    expect(subscription)
      .to have_stream_for(gallery)
  end

  it "transmits unprocessed IDs on subscribe" do
    user = create(:user)
    gallery = create(:gallery, user:)
    unprocessed = create(
      :galleries_image,
      gallery:,
      processed_at: nil
    )
    create(
      :galleries_image,
      gallery:,
      processed_at: Time.current
    )
    stub_connection(current_user: user)

    subscribe(gallery_id: gallery.id)

    expect(transmissions.last).to eq(
      "action" => "reconcile",
      "unprocessed_ids" => [unprocessed.id]
    )
  end

  it "transmits unprocessed IDs on sync" do
    user = create(:user)
    gallery = create(:gallery, user:)
    unprocessed = create(
      :galleries_image,
      gallery:,
      processed_at: nil
    )
    stub_connection(current_user: user)
    subscribe(gallery_id: gallery.id)

    perform(:sync)

    expect(transmissions.last).to eq(
      "action" => "reconcile",
      "unprocessed_ids" => [unprocessed.id]
    )
  end
end
