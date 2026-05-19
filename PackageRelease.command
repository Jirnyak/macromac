#!/bin/zsh
set -e

cd "$(dirname "$0")"

archive_name="MacroMac-macos-universal.zip"
binary_path=".build/apple/Products/Release/macro"
if ! swift build -c release --arch arm64 --arch x86_64; then
  swift build -c release
  archive_name="MacroMac-macos-$(uname -m).zip"
  binary_path=".build/release/macro"
fi

rm -rf dist/MacroMac dist/MacroMac-macos-*.zip
mkdir -p dist/MacroMac/macros

cp "$binary_path" dist/MacroMac/macro
cp LICENSE dist/MacroMac/LICENSE
cp README.md dist/MacroMac/README.md
cp macros/example.json dist/MacroMac/macros/example.json
cp macro.config.example.json dist/MacroMac/macro.config.example.json

cat > dist/MacroMac/Macro.command <<'EOF'
#!/bin/zsh
cd "$(dirname "$0")"
exec ./macro
EOF

cat > dist/MacroMac/Example.command <<'EOF'
#!/bin/zsh
cd "$(dirname "$0")"
exec ./macro --runner --play --macro example.json
EOF

cat > dist/MacroMac/Hotkeys.command <<'EOF'
#!/bin/zsh
cd "$(dirname "$0")"
exec ./macro --hotkeys
EOF

chmod +x dist/MacroMac/macro dist/MacroMac/Macro.command dist/MacroMac/Example.command dist/MacroMac/Hotkeys.command

printf '%s\n' "$archive_name" > dist/archive-name.txt
(cd dist && zip -qry "$archive_name" MacroMac)

echo "Packaged: dist/MacroMac"
echo "Archive: dist/$archive_name"
