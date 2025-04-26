# GuardianCare

An intuitive health management application designed specifically for elderly users. GuardianCare helps seniors monitor their health, manage medications, schedule medical appointments, and connect with caregivers.

![GuardianCare Logo](assets/images/logo.png)

## Features

- **Medication Management**: Track prescriptions, get reminders, and mark medications as taken
- **Health Monitoring**: Record and visualize vital signs like heart rate and blood pressure
- **Appointment Scheduling**: Book in-person or virtual consultations with healthcare providers
- **Emergency Assistance**: Quick access to emergency services with one tap
- **Calendar View**: See all health events in one organized calendar
- **Customizable Reminders**: Set alerts for medications, appointments, and more

## Accessibility Features

GuardianCare is designed with accessibility in mind:
- Large, easy-to-read text and buttons
- High contrast color schemes
- Simple navigation with clear labels
- Voice command capabilities (coming soon)
- Support for screen readers

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code with Flutter plugins
- Firebase account for authentication (optional)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/guardian-care.git
cd guardian-care
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Dependencies

- `flutter`: Core framework
- `firebase_core`: Firebase integration
- `firebase_auth`: Authentication services
- `google_sign_in`: Google authentication
- `intl`: Internationalization and date formatting
- `url_launcher`: For launching phone calls
- `table_calendar`: Calendar view
- `fl_chart`: Interactive health data charts

## Architecture

The app follows a simple, maintainable architecture:
- **Models**: Data classes for medications, appointments, health stats
- **Screens**: UI components organized by feature
- **Services**: Business logic and API integration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
