# VaultX 🔐

VaultX is a secure, end-to-end encrypted password management application built with Flutter and Firebase. It allows users to store sensitive account information with AES-256 encryption, ensuring that only the user can access their data.

## 🚀 Live Demo & Download
* **Web Version:** [https://meetakashn.github.io/vaultx/](https://meetakashn.github.io/vaultx/)
* **Android App:** [Download APK from Releases](https://github.com/meetakashn/vaultx/releases)

## ✨ Key Features
* **AES-256 Encryption:** All sensitive fields are encrypted locally using a master key.
* **Firebase Integration:** Secure cloud sync across devices using Firestore.
* **Password Generator:** Built-in tool to create strong, random passwords.
* **Modern UI:** Clean, dark-themed interface built for speed and security.

## 🛠️ Security Architecture
VaultX uses a layered security approach:
1. **PBKDF2:** For deriving encryption keys from user passwords.
2. **AES-CBC:** For encrypting the actual vault data.
3. **SHA-256:** For deterministic key generation for specific vault fields.

## ⚙️ Setup Instructions (For Developers)
To run this project locally, you must provide your own Firebase configuration:

1. **Firebase Project:** Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. **Android Setup:** Download your `google-services.json` and place it in `android/app/`.
3. **Flutterfire:** Run `flutterfire configure` to generate your `lib/firebase_options.dart`.
4. **Dependencies:** Run `flutter pub get`.
5. **Run:** Execute `flutter run`.

---
*Developed by [meetakashn](https://github.com/meetakashn)*
