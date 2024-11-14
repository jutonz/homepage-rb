// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

document.addEventListener('direct-upload:initialize', (event) => {
  const { target, detail } = event;
  console.log(`Starting to upload ${detail.file.name}`);
});

document.addEventListener('direct-upload:progress', (event) => {
  const { target, detail } = event;
  console.log(`File ${detail.file.name} is ${detail.progress}% uploaded.`);
});

document.addEventListener('direct-upload:end', (event) => {
  const { target, detail } = event;
  console.log(`File ${detail.file.name} finished uploading.`);
});

