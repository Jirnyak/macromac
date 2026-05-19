#!/bin/zsh
set -e

cd "$(dirname "$0")/.."
swift scripts/render-demo-gif.swift
