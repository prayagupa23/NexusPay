# NexusPay - Fraud Detection & Security App

A comprehensive Flutter application for secure financial transactions with advanced fraud detection, trusted contacts management, and real-time security monitoring.

## 🚀 Features

### 🔐 Security & Authentication
- **Biometric Authentication** - Fingerprint and face recognition
- **Secure Login** - Encrypted user authentication
- **Screenshot Protection** - Prevents unauthorized screen captures
- **Session Management** - Secure user sessions with auto-logout

### 🛡️ Fraud Detection
- **Real-time Fraud Alerts** - Instant notifications for suspicious activities
- **Fraud Intelligence Center** - Centralized fraud monitoring dashboard
- **Transaction Analysis** - AI-powered fraud pattern recognition
- **Risk Assessment** - Dynamic risk scoring for transactions

### 👥 Trusted Contacts
- **Contact Management** - Add and manage trusted contacts
- **Contact Verification** - Verify contact authenticity
- **Emergency Contacts** - Quick access to trusted contacts
- **Contact Analytics** - Transaction history with contacts

### 📍 Location Services
- **Current Location** - Real-time location tracking
- **Interactive Maps** - OpenStreetMap integration
- **Location-based Security** - Geofencing for transactions
- **Privacy-focused** - No Google API dependencies

### 📊 Analytics & Insights
- **Fraud Heatmap** - Visual representation of fraud activities
- **Transaction Analytics** - Detailed spending analysis
- **Security Reports** - Comprehensive security insights
- **Dashboard Metrics** - Real-time security statistics

### 🎨 User Experience
- **Dark/Light Theme** - Adaptive theme switching
- **Material Design** - Modern, intuitive UI
- **Responsive Design** - Optimized for all screen sizes
- **Accessibility** - Full accessibility support

## 🛠️ Technology Stack

### Core Framework
- **Flutter** ^3.8.1 - Cross-platform development framework
- **Dart** - Programming language

### Backend & Database
- **Supabase** - Backend-as-a-Service with PostgreSQL
- **Real-time Database** - Live data synchronization
- **Authentication** - Secure user management

### Key Dependencies
- **geolocator** ^10.1.0 - Location services
- **flutter_map** ^5.0.0 - OpenStreetMap integration
- **permission_handler** ^11.3.1 - Runtime permissions
- **local_auth** ^2.3.0 - Biometric authentication
- **flutter_contacts** ^1.1.6 - Contact management
- **google_ml_kit** ^0.20.0 - Machine learning capabilities
- **shared_preferences** ^2.3.2 - Local data storage
- **image_picker** ^1.2.1 - Image handling
- **flutter_tts** ^3.8.5 - Text-to-speech
- **speech_to_text** ^7.0.0 - Voice recognition

### UI & Design
- **google_fonts** ^6.3.2 - Typography
- **flutter_local_notifications** ^19.5.0 - Push notifications
- **fluttertoast** ^8.2.4 - Toast messages

## 📱 Installation

### Prerequisites
- Flutter SDK ^3.8.1
- Dart SDK compatible with Flutter version
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/heisenbug.git
   cd heisenbug
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment setup**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Add your Supabase credentials
   # SUPABASE_URL=your_supabase_url
   # SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build for production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## 🔧 Configuration

### Android Setup
1. **Location Permissions** - Already configured in `android/app/src/main/AndroidManifest.xml`
2. **Biometric Permissions** - Included in manifest
3. **Internet Permissions** - Required for API calls

### iOS Setup
1. **Location Permissions** - Add to `Info.plist`
2. **Biometric Permissions** - Configure in Xcode
3. **Camera Permissions** - For image picker functionality

### Supabase Configuration
1. Create a new project at [supabase.com](https://supabase.com)
2. Set up authentication providers
3. Configure database schema
4. Update environment variables

## 📁 Project Structure

## 🔐 Security Features

### Data Protection
- **End-to-end Encryption** - All data encrypted in transit
- **Secure Storage** - Sensitive data stored securely
- **API Security** - JWT-based authentication
- **Input Validation** - Comprehensive input sanitization

### Privacy Features
- **Location Privacy** - User-controlled location sharing
- **Data Minimization** - Only collect necessary data
- **Anonymous Analytics** - Privacy-focused analytics
- **GDPR Compliance** - Data protection regulations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comments for complex logic
- Include unit tests for new features

## 🐛 Troubleshooting

### Common Issues

1. **Location permissions not working**
   - Ensure permissions are in AndroidManifest.xml
   - Check runtime permission handling
   - Verify location services are enabled

2. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter version compatibility
   - Update dependencies

3. **Supabase connection issues**
   - Verify environment variables
   - Check network connectivity
   - Validate Supabase configuration
