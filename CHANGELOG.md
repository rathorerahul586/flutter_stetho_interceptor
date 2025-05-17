# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2025-05-17

### Added
- Initial release of `flutter_stetho_interceptor`.
- Support for intercepting HTTP requests using Dart's `HttpClient`.
- Integration with [Facebook Stetho](https://github.com/facebook/stetho) for network inspection in Chrome DevTools.
- Android-only support.
- `StethoFlutter.initialize()` for initializing Stetho.
- Custom `HttpOverrides` to hook into requests.
- Request/response monitoring with headers and body streaming.
- Utility UUID generator and header serialization.
- Example app demonstrating API calls (`fetchJson`, `fetchImage`, `fetchError`).
- README with usage instructions and setup.
- License and pubspec metadata.

---
