module TurboHelpers
  def wait_for_turbo
    expect(page).not_to have_css("html[aria-busy='true']")
    expect(page).not_to have_css("html[data-turbo-preview]")
    expect(page).not_to have_css("turbo-frame[busy]")
  end
end
