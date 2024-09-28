module CapybaraPage
  def page
    Capybara.string(response.body)
  end
end
