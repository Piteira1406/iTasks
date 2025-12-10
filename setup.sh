#!/bin/bash

# iTasks - Setup Script
# Este script configura o ambiente de desenvolvimento

set -e  # Exit on error

echo "🚀 iTasks - Setup Script"
echo "========================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não está instalado!"
    echo "📥 Instale o Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter encontrado: $(flutter --version | head -n 1)"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI não encontrado"
    echo "📥 Instale com: npm install -g firebase-tools"
    echo ""
fi

# Install Flutter dependencies
echo "📦 Instalando dependências Flutter..."
flutter pub get
echo "✅ Dependências instaladas"
echo ""

# Check for Firebase configuration
echo "🔍 Verificando configuração Firebase..."

if [ ! -f "lib/firebase_options.dart" ]; then
    echo "⚠️  firebase_options.dart não encontrado"
    echo ""
    echo "Escolha uma opção:"
    echo "1) Usar FlutterFire CLI (Recomendado)"
    echo "2) Configurar manualmente"
    read -p "Opção (1 ou 2): " option
    
    if [ "$option" = "1" ]; then
        echo ""
        echo "📱 Configurando com FlutterFire CLI..."
        
        # Check if FlutterFire CLI is installed
        if ! command -v flutterfire &> /dev/null; then
            echo "📥 Instalando FlutterFire CLI..."
            dart pub global activate flutterfire_cli
        fi
        
        echo "🔧 Execute agora: flutterfire configure"
        echo "   Siga as instruções para conectar ao seu projeto Firebase"
        
    elif [ "$option" = "2" ]; then
        echo ""
        echo "📝 Configuração manual:"
        echo "1. Copie: cp lib/firebase_options.example.dart lib/firebase_options.dart"
        echo "2. Edite lib/firebase_options.dart com suas credenciais Firebase"
        echo "3. Baixe google-services.json da Firebase Console"
        echo "4. Copie para: android/app/google-services.json"
        echo "5. Para iOS, baixe GoogleService-Info.plist"
        echo "6. Copie para: ios/Runner/GoogleService-Info.plist"
    fi
else
    echo "✅ firebase_options.dart encontrado"
fi
echo ""

# Check for google-services.json
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  android/app/google-services.json não encontrado"
    echo "   Baixe da Firebase Console para suporte Android"
else
    echo "✅ google-services.json encontrado"
fi
echo ""

# Check for .firebaserc
if [ ! -f ".firebaserc" ]; then
    echo "⚠️  .firebaserc não encontrado"
    if [ -f ".firebaserc.example" ]; then
        echo "📝 Criando .firebaserc..."
        cp .firebaserc.example .firebaserc
        echo "   Edite .firebaserc com seu Firebase Project ID"
    fi
else
    echo "✅ .firebaserc encontrado"
fi
echo ""

# Run Flutter doctor
echo "🏥 Verificando ambiente Flutter..."
flutter doctor
echo ""

echo "✨ Setup concluído!"
echo ""
echo "📋 Próximos passos:"
echo "1. Complete a configuração Firebase (se necessário)"
echo "2. Execute: flutter run"
echo "3. Escolha o dispositivo/emulador desejado"
echo ""
echo "📚 Documentação: README.md"
echo "🔒 Segurança: SECURITY.md"
echo ""
echo "Bom desenvolvimento! 🚀"
