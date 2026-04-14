#!/usr/bin/env bash
# Generic build verifier that auto-detects project type.
# Usage: verify_build.sh [project_dir]

set -e
PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

detect_and_build() {
    # iOS (Xcode workspace)
    if ls *.xcworkspace 1>/dev/null 2>&1; then
        WORKSPACE=$(ls *.xcworkspace | head -1)
        SCHEME="${WORKSPACE%.xcworkspace}"
        echo "🍎 Detected iOS project: $WORKSPACE"
        xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
            build 2>&1 | grep -E "error:|BUILD"
        return $?
    fi

    # iOS (Xcode project without workspace)
    if ls *.xcodeproj 1>/dev/null 2>&1; then
        PROJ=$(ls *.xcodeproj | head -1)
        SCHEME="${PROJ%.xcodeproj}"
        echo "🍎 Detected iOS project: $PROJ"
        xcodebuild -project "$PROJ" -scheme "$SCHEME" \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
            build 2>&1 | grep -E "error:|BUILD"
        return $?
    fi

    # Android (Gradle)
    if [[ -f "gradlew" ]]; then
        echo "🤖 Detected Android project (Gradle)"
        ./gradlew assembleDebug
        return $?
    fi

    # Flutter
    if [[ -f "pubspec.yaml" ]]; then
        echo "🐦 Detected Flutter project"
        flutter build apk --debug
        return $?
    fi

    # Node.js / Web
    if [[ -f "package.json" ]]; then
        echo "🌐 Detected Node project"
        npm run build
        return $?
    fi

    echo "❓ Unknown project type. Add detection for your stack in scripts/verify_build.sh"
    return 1
}

detect_and_build
