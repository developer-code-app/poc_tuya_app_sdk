class Device {
  Device({
    required this.deviceId,
    required this.name,
    required this.isZigBeeWifi,
  });

  factory Device.fromMap(Map map) {
    return Device(
      deviceId: map['device_id'],
      name: map['name'],
      isZigBeeWifi: map['is_zig_bee_wifi'],
    );
  }

  final String deviceId;
  final String name;
  final bool isZigBeeWifi;
}
