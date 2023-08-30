class Device {
  Device({
    required this.deviceId,
    required this.name,
    required this.roomName,
  });

  factory Device.fromMap(Map map) {
    return Device(
      deviceId: map['device_id'],
      name: map['name'],
      roomName: map['room_name'],
    );
  }

  final String deviceId;
  final String name;
  final String roomName;
}
