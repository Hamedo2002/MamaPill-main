enum AppStatus {
  initial,
  authenticated,
  unauthenticated,
  error,
}

enum AuthStatus { initial, submiting, success, failure }

enum MedicineType { capsule, tablet, liquid, injection }

enum MedicineStatus { pending, taken, skipped }

enum RequestStatus { initial, loading, success, failure }
