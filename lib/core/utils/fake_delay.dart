/// Simulates network latency for mock services.
Future<void> fakeDelay([Duration duration = const Duration(milliseconds: 650)]) {
  return Future<void>.delayed(duration);
}

