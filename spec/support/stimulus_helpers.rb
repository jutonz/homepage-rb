module StimulusHelpers
  def wait_for_stimulus(identifier)
    expect(page).to have_css("[data-#{identifier}-loaded='true']", visible: :all)
  end
end
