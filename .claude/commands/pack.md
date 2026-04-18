Package the Chrome Extension as a .zip file ready for Chrome Web Store upload.

Steps:
1. First run /build to ensure dist/ is up to date
2. Create `releases/` directory if it doesn't exist
3. Zip the contents of `dist/` into `releases/extension-$(date +%Y%m%d-%H%M%S).zip`
4. Print the zip file path and size

The zip must contain files at the root level (not inside a subfolder), so cd into dist/ before zipping.
