import 'dart:math';

import 'package:android_tools/core/constant/ssid.dart';
import 'package:android_tools/features/home/domain/entity/device_info.dart';

DeviceInfo generateRandomDeviceInfo() {
  final randomDevice = deviceInfoList[Random().nextInt(deviceInfoList.length)];
  const realSdkVersion = "29"; // Set to your Mi A1’s actual SDK (28 or 29)
  return DeviceInfo(
    model: randomDevice.model,
    brand: randomDevice.brand,
    manufacturer: randomDevice.manufacturer,
    serialNo:
        generateSerialNumber(randomDevice.manufacturer),
    device: randomDevice.device,
    productName: randomDevice.productName,
    releaseVersion: randomDevice.releaseVersion,
    sdkVersion: realSdkVersion,
    macAddress: generateRandomMacAddress(),
    fingerprint: generateFingerPrint(randomDevice),
    androidId: generateAndroidId(),
    ssid: getRandomSSID(),
    advertisingId: generateAdvertisingId(),
    width: randomDevice.width,
    height: randomDevice.height,
    imei: generateRandomImei(),
  );
}

String generateFingerPrint(DeviceInfo baseDevice) {
  final Random random = Random();
  final buildNumber = (random.nextInt(90000) + 10000).toString();
  final fingerprint =
      "${baseDevice.brand}/${baseDevice.productName}/${baseDevice.device}:${baseDevice.releaseVersion}/${baseDevice.sdkVersion}/release-keys:user/$buildNumber";
  return fingerprint;
}

String generateRandomMacAddress() {
  final Random rand = Random();
  final List<int> mac = List.generate(6, (_) => rand.nextInt(256));

  // Ensure locally administered and unicast MAC address
  mac[0] = (mac[0] & 0xFC) | 0x02;

  return mac
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(':');
}

String generateSerialNumber(String manufacturer) {
  final random = Random();

  // Base serial number patterns by manufacturer
  String prefix;
  int length;

  switch (manufacturer.toLowerCase()) {
    case 'samsung':
    // Samsung often uses 'R' or 'S' prefixes with mixed alphanumeric
      prefix = 'R${random.nextInt(9) + 1}'; // e.g., R5
      length = 11; // Common Samsung length
      break;
    case 'oneplus':
    // OnePlus tends to use shorter numeric or mixed serials
      prefix = 'OP'; // e.g., OP
      length = 10;
      break;
    case 'google':
    // Google Pixel uses simpler numeric or mixed serials
      prefix = 'G'; // e.g., G
      length = 12;
      break;
    case 'sony':
    // Sony often uses 'FA' or similar prefixes
      prefix = 'FA${random.nextInt(9)}'; // e.g., FA7
      length = 12;
      break;
    case 'xiaomi':
    // Xiaomi varies widely, often numeric or mixed
      prefix = 'XM'; // e.g., XM
      length = 10;
      break;
    default:
      prefix = 'SN'; // Generic fallback
      length = 10;
  }

  // Generate random alphanumeric suffix
  const String chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String suffix = String.fromCharCodes(
    List.generate(
      length - prefix.length,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );

  return prefix + suffix;
}
String generateAndroidId() {
  // Android ID is a 16-character hex string
  const chars = '0123456789abcdef';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      16,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

String generateAdvertisingId() {
  final Random random = Random.secure();
  const String hexDigits = "0123456789abcdef";

  String randomHex(int length) {
    return List.generate(length, (_) => hexDigits[random.nextInt(16)]).join();
  }

  return "${randomHex(8)}-${randomHex(4)}-4${randomHex(3)}-${["8", "9", "a", "b"][random.nextInt(4)]}${randomHex(3)}-${randomHex(12)}";
}

String generateRandomImei() {
  // Generate a random 8-digit TAC (e.g., starting with a plausible prefix)
  // Using 35 as a fake starting point (common for test IMEIs)
  String tac = '35${Random().nextInt(999999).toString().padLeft(6, '0')}';

  // Generate a random 6-digit serial number
  String serial = Random().nextInt(999999).toString().padLeft(6, '0');

  // Combine TAC and serial (14 digits so far)
  String baseImei = tac + serial;

  // Calculate the check digit using the Luhn algorithm
  int checkDigit = calculateLuhnCheckDigit(baseImei);

  // Return the full 15-digit IMEI
  return baseImei + checkDigit.toString();
}

// Luhn algorithm to calculate the check digit
int calculateLuhnCheckDigit(String number) {
  int sum = 0;
  bool alternate = true; // Start with the second-to-last digit

  // Iterate from right to left
  for (int i = number.length - 1; i >= 0; i--) {
    int digit = int.parse(number[i]);

    if (alternate) {
      digit *= 2;
      if (digit > 9) digit -= 9; // If doubling results in >9, subtract 9
    }

    sum += digit;
    alternate = !alternate;
  }

  // The check digit makes the total sum divisible by 10
  return (10 - (sum % 10)) % 10;
}
