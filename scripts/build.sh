#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$REPO_ROOT/src/BlazorExtension/BlazorExtension.csproj"
PUBLISH_OUT="$REPO_ROOT/publish"
DIST="$REPO_ROOT/dist"

echo "==> Building Blazor WASM..."
dotnet publish "$PROJECT" -c Release -o "$PUBLISH_OUT" --nologo

echo "==> Copying to dist/..."
rm -rf "$DIST"
cp -r "$PUBLISH_OUT/wwwroot/." "$DIST"

# Chrome Extension은 '_' 로 시작하는 디렉토리명을 허용하지 않는다.
# Blazor가 생성하는 _framework/ → framework/ 로 rename 후 참조 패치.
echo "==> Renaming _framework/ → framework/..."
mv "$DIST/_framework" "$DIST/framework"

# .br / .gz 압축 파일은 Extension에서 사용되지 않으므로 제거 (크기 절약)
echo "==> Removing unused compressed files (.br, .gz)..."
find "$DIST" -name "*.br" -delete
find "$DIST" -name "*.gz" -delete

# index.html 및 JS 파일 안의 '_framework' 경로 참조를 'framework'로 일괄 치환
# macOS BSD sed 사용 (-i '' 방식)
echo "==> Patching '_framework' references → 'framework'..."
sed -i '' 's|_framework/|framework/|g' "$DIST/index.html"
find "$DIST/framework" -name "*.js" -exec sed -i '' 's|_framework/|framework/|g' {} +

echo "==> Verifying manifest.json..."
if [ ! -f "$DIST/manifest.json" ]; then
  echo "ERROR: manifest.json not found in dist/" >&2
  exit 1
fi

echo ""
echo "✅ Build complete. dist/ contents:"
ls "$DIST"
