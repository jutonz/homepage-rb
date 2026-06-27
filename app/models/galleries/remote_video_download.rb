module Galleries
  class RemoteVideoDownload < ApplicationRecord
    belongs_to :gallery
    belongs_to :image,
      class_name: "Galleries::Image",
      optional: true

    enum :status,
      {
        pending: "pending",
        downloading: "downloading",
        completed: "completed",
        failed: "failed"
      },
      validate: true,
      prefix: true

    validates :url, presence: true
  end
end
