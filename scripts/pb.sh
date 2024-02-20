#!/bin/sh

set -e

PATH="$PATH":"$HOME/.pub-cache/bin":"$HOME/fvm/default/bin"

# Dart
rm -rf lib/proto/*
protoc -I=proto --dart_out=lib/proto proto/schema.pb

# Kotlin
rm -rf android/app/src/main/kotlin/com/enm10k/anatomy/pb/*
protoc -I=proto --java_out=lite:android/app/src/main/kotlin/com/enm10k/anatomy/pb --kotlin_out=android/app/src/main/kotlin/com/enm10k/anatomy/pb proto/schema.pb

