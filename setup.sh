#!/bin/bash

echo "🚀 AgileAI AI - Setup Script"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter ist nicht installiert!"
    echo "Bitte installiere Flutter von: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter gefunden: $(flutter --version | head -1)"
echo ""

# Install dependencies
echo "📦 Installiere Dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Fehler beim Installieren der Dependencies"
    exit 1
fi

echo ""
echo "🔨 Generiere Code (JSON Serialization)..."
dart run build_runner build --delete-conflicting-outputs

if [ $? -ne 0 ]; then
    echo "❌ Fehler beim Generieren des Codes"
    exit 1
fi

echo ""
echo "✅ Setup erfolgreich abgeschlossen!"
echo ""
echo "⚠️  WICHTIG: Füge deinen Google Gemini API Key ein:"
echo "   1. Öffne: lib/config/app_config.dart"
echo "   2. Ersetze: 'YOUR_GEMINI_API_KEY_HERE' mit deinem API Key"
echo "   3. API Key erstellen: https://makersuite.google.com/app/apikey"
echo ""
echo "▶️  App starten:"
echo "   flutter run                # Android/iOS (Simulator)"
echo "   flutter run -d windows     # Windows"
echo "   flutter run -d macos       # macOS"
echo ""
echo "Viel Erfolg! 🎉"
