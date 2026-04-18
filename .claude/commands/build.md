Build the Blazor WASM project and copy output to dist/ for Chrome Extension loading.

Steps:
1. Run `dotnet publish src/BlazorExtension/BlazorExtension.csproj -c Release -o publish/`
2. Clean and recreate `dist/` directory
3. Copy `publish/wwwroot/` contents into `dist/`
4. Verify `dist/manifest.json` exists
5. Report the final file list in `dist/`

If any step fails, stop and report the error clearly.
