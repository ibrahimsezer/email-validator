# Email Validator

[![Dart](https://img.shields.io/badge/Dart-3.6.0-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An e-mail verification tool including format verification, domain validation and MX recording control.

## Features

- **Email Format Validation**: Validates email addresses against standard format rules
- **Domain Validation**: Verifies if the email domain is active and accessible
- **MX Record Checking**: Retrieves and displays MX (Mail Exchange) records for the email domain
- **CSV Export**: Automatically exports validation results to a CSV file with timestamp

## Installation

1. Ensure you have Dart SDK installed (version ^3.6.0)
2. Clone the repository:
   ```bash
   git clone https://github.com/ibrahimsezer/email-validator.git
   ```
3. Navigate to the project directory:
   ```bash
   cd email-validator
   ```
4. Install dependencies:
   ```bash
   dart pub get
   ```

## Usage

Run the application using:
```bash
dart run
```

The program will:
1. Prompt you to enter an email address
2. Validate the email format
3. Check domain validity
4. Retrieve MX records
5. Save results to a CSV file
6. Allow you to check multiple emails in one session

## Dependencies

- http: ^1.3.0 - For making HTTP requests
- csv: ^6.0.0 - For CSV file operations
- intl: ^0.20.2 - For date formatting

## Testing

Run tests using:
```bash
dart test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

👤 **Ibrahim Sezer**

- GitHub: [@ibrahimsezer](https://github.com/ibrahimsezer)
- Portfolio: [ibrahimsezer.github.io](https://ibrahimsezer.github.io)

## License

This project is [MIT](https://opensource.org/licenses/MIT) licensed.
