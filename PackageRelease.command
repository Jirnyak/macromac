#!/bin/zsh
set -e

cd "$(dirname "$0")"
swift build -c release

rm -rf dist/Macro
mkdir -p dist/Macro/macros

cp .build/release/macro dist/Macro/macro
cp macros/example.json dist/Macro/macros/example.json

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

chmod +x dist/Macro/macro dist/Macro/Macro.command dist/Macro/Example.command

echo "Packaged: dist/Macro"
