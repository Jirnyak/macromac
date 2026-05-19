#!/bin/zsh
set -e

cd "$(dirname "$0")"
swift build -c release --arch arm64 --arch x86_64

rm -rf dist/MacroMac dist/MacroMac-macos-universal.zip
mkdir -p dist/MacroMac/macros

cp .build/apple/Products/Release/macro dist/MacroMac/macro
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

(cd dist && zip -qry MacroMac-macos-universal.zip MacroMac)

echo "Packaged: dist/MacroMac"
echo "Archive: dist/MacroMac-macos-universal.zip"
