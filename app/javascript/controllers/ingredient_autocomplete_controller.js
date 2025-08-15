import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "suggestion"]
  static values = { suggestions: Array }

  connect() {
    this.filteredSuggestions = this.suggestionsValue
    this.selectedIndex = -1
    this.isDropdownVisible = false
    
    // Close dropdown when clicking outside
    this.boundCloseDropdown = this.closeDropdown.bind(this)
    document.addEventListener('click', this.boundCloseDropdown)
  }

  disconnect() {
    document.removeEventListener('click', this.boundCloseDropdown)
  }

  filter(event) {
    const query = event.target.value.toLowerCase().trim()
    
    if (query.length === 0) {
      this.hideDropdown()
      return
    }

    // Filter suggestions based on the query
    this.filteredSuggestions = this.suggestionsValue.filter(suggestion => 
      suggestion.name.toLowerCase().includes(query)
    )

    this.selectedIndex = -1
    this.showDropdown()
    this.renderSuggestions()
  }

  navigate(event) {
    if (!this.isDropdownVisible) return

    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.filteredSuggestions.length - 1)
        this.updateSelection()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.updateSelection()
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0) {
          this.selectSuggestion(this.filteredSuggestions[this.selectedIndex])
        }
        break
      case 'Escape':
        event.preventDefault()
        this.hideDropdown()
        break
    }
  }

  selectSuggestion(suggestion) {
    this.inputTarget.value = suggestion.name
    this.hideDropdown()
    this.inputTarget.focus()
  }

  clickSuggestion(event) {
    const suggestionData = JSON.parse(event.currentTarget.dataset.suggestion)
    this.selectSuggestion(suggestionData)
  }

  showDropdown() {
    this.isDropdownVisible = true
    this.dropdownTarget.classList.remove('hidden')
    this.dropdownTarget.setAttribute('aria-hidden', 'false')
  }

  hideDropdown() {
    this.isDropdownVisible = false
    this.dropdownTarget.classList.add('hidden')
    this.dropdownTarget.setAttribute('aria-hidden', 'true')
    this.selectedIndex = -1
  }

  closeDropdown(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  renderSuggestions() {
    if (this.filteredSuggestions.length === 0) {
      this.dropdownTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-gray-500 italic">
          No existing ingredients found. Type to create a new one.
        </div>
      `
      return
    }

    this.dropdownTarget.innerHTML = this.filteredSuggestions
      .map((suggestion, index) => `
        <div 
          class="suggestion-item px-4 py-3 cursor-pointer hover:bg-gray-50 transition-colors duration-150 text-sm"
          data-suggestion='${JSON.stringify(suggestion)}'
          data-action="click->ingredient-autocomplete#clickSuggestion"
          data-index="${index}"
        >
          ${suggestion.name}
        </div>
      `).join('')
  }

  updateSelection() {
    const items = this.dropdownTarget.querySelectorAll('.suggestion-item')
    
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-blue-50', 'text-blue-700')
        item.classList.remove('hover:bg-gray-50')
      } else {
        item.classList.remove('bg-blue-50', 'text-blue-700')
        item.classList.add('hover:bg-gray-50')
      }
    })
  }
}