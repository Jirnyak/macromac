#!/bin/zsh
set -e

cd "$(dirname "$0")"
swift build -c release

rm -rf dist/Macro
mkdir -p dist/Macro/macros

cp .build/release/macro dist/Macro/macro
cp macros/example.json dist/Macro/macros/example.json
cp macro.config.example.json dist/Macro/macro.config.example.json

cat > dist/Macro/Macro.command <<'EOF'
#!/bin/zsh
cd "$(dirname "$0")"
exec ./macro
EOF

cat > dist/Macro/Example.command <<'EOF'
#!/bin/zsh
cd "$(dirname "$0")"
exec ./macro --runner --play --macro example.json
EOF

cat > dist/Macro/Hotkeys.command <<'EOF'
#!/bin/zsh
cd "$(dirname "$0")"
exec ./macro --hotkeys
EOF

chmod +x dist/Macro/macro dist/Macro/Macro.command dist/Macro/Example.command dist/Macro/Hotkeys.command

echo "Packaged: dist/Macro"
