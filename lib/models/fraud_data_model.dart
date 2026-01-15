class FraudData {
  final String serialNumber;
  final String stateName;
  final int fraudCases;

  FraudData({
    required this.serialNumber,
    required this.stateName,
    required this.fraudCases,
  });

  @override
  String toString() {
    return 'FraudData(serialNumber: $serialNumber, stateName: $stateName, fraudCases: $fraudCases)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FraudData &&
        other.serialNumber == serialNumber &&
        other.stateName == stateName &&
        other.fraudCases == fraudCases;
  }

  @override
  int get hashCode =>
      serialNumber.hashCode ^ stateName.hashCode ^ fraudCases.hashCode;
}
