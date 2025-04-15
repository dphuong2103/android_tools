import 'dart:math';

import 'package:android_tools/core/constant/ssid.dart';
import 'package:android_tools/features/home/domain/entity/base_device_info.dart';
import 'package:android_tools/features/home/domain/entity/device_info.dart';

Random _random = Random();

DeviceInfo generateRandomDeviceInfo() {
  final randomDevice = baseDeviceInfoList[_random.nextInt(baseDeviceInfoList.length)];
  final fingerPrint = generateFingerPrint(randomDevice);
  final countryData = generateCountryData();
  final serialNumber = generateSerialNumber(randomDevice.manufacturer);
  return DeviceInfo(
    model: randomDevice.model,
    brand: randomDevice.brand,
    manufacturer: randomDevice.manufacturer,
    serialNo: serialNumber,
    device: randomDevice.device,
    productName: randomDevice.productName,
    releaseVersion: randomDevice.releaseVersion,
    sdkVersion: randomDevice.sdkVersion,
    macAddress: generateRandomMacAddress(),
    fingerprint: fingerPrint,
    androidId: generateAndroidId(),
    ssid: getRandomSSID(),
    advertisingId: generateAdvertisingId(),
    width: randomDevice.width,
    height: randomDevice.height,
    imei: generateRandomImei(randomDevice.manufacturer),
    subscriberId: generateSubscriberId(countryData['mcc']!),
    androidSerial: serialNumber,
    phoneNumber: countryData['phoneNumber']!,
    host: generateHost(),
    serialSimNumber: generateSerialSimNumber(countryData['mcc']!),
    bssid: generateRandomMacAddress(),
    operator: countryData['operator']!,
    operatorName: countryData['operatorName']!,
    countryIso: countryData['countryIso']!,
    wifiIp: generateWifiIp(),
    userAgent: getUserAgent(
      randomDevice.model,
      randomDevice.releaseVersion,
      fingerPrint,
      randomDevice.versionChrome,
    ),
    osVersion: randomDevice.releaseVersion,
    glVendor: randomDevice.glVendor,
    glRender: randomDevice.glRender,
    hardware: randomDevice.hardware,
    id: randomDevice.id,
    radio: randomDevice.radio,
    bootloader: randomDevice.bootloader,
    display: randomDevice.display,
    board: randomDevice.board,
    codename: randomDevice.codename,
    macHardware: randomDevice.macHardware,
    versionChrome: randomDevice.versionChrome,
  );
}

String _getGlVendor(String model) {
  switch (model) {
    case "Redmi Note 7":
    case "Mi 8 Lite":
    case "Redmi 8":
    case "A6010":
    case "AC2003":
    case "Pixel 3":
    case "Pixel 4a":
    case "XQ-AU52":
    case "J8210":
    case "CPH2067":
      return "Qualcomm";
    case "SM-A505F":
    case "SM-M315F":
    case "SM-G960F":
    case "RMX2001":
      return "ARM";
    default:
      return "Qualcomm";
  }
}

String _getGlRender(String model) {
  switch (model) {
    case "Redmi Note 7":
      return "Adreno 512";
    case "Mi 8 Lite":
      return "Adreno 616";
    case "Redmi 8":
      return "Adreno 505";
    case "SM-A505F":
    case "SM-M315F":
      return "Mali-G72 MP3";
    case "SM-G960F":
      return "Mali-G72 MP18";
    case "A6010":
      return "Adreno 630";
    case "AC2003":
      return "Adreno 620";
    case "Pixel 3":
      return "Adreno 630";
    case "Pixel 4a":
      return "Adreno 618";
    case "XQ-AU52":
    case "CPH2067":
      return "Adreno 610";
    case "J8210":
      return "Adreno 640";
    case "RMX2001":
      return "Mali-G76 MC4";
    default:
      return "Adreno 505";
  }
}

String _getHardware(String model) {
  switch (model) {
    case "Redmi Note 7":
    case "Mi 8 Lite":
    case "Redmi 8":
    case "A6010":
    case "AC2003":
    case "Pixel 3":
    case "Pixel 4a":
    case "XQ-AU52":
    case "J8210":
    case "CPH2067":
      return "qcom";
    case "SM-A505F":
    case "SM-M315F":
      return "exynos9611";
    case "SM-G960F":
      return "exynos9810";
    case "RMX2001":
      return "mediatek";
    default:
      return "qcom";
  }
}

String _getId(String fingerprint) {
  return fingerprint.split('/')[2].split(':')[1];
}

String _getBootloader(String brand) {
  return brand.toLowerCase() == "samsung" ? "u1.0.0" : "b1.0.0";
}

String _getBoard(String model) {
  switch (model) {
    case "Redmi Note 7":
    case "Mi 8 Lite":
      return "sdm660";
    case "Redmi 8":
      return "sdm439";
    case "SM-A505F":
    case "SM-M315F":
      return "exynos9611";
    case "SM-G960F":
      return "exynos9810";
    case "A6010":
      return "sdm845";
    case "AC2003":
      return "sdm765";
    case "Pixel 3":
      return "sdm845";
    case "Pixel 4a":
      return "sdm730";
    case "XQ-AU52":
    case "CPH2067":
      return "sdm665";
    case "J8210":
      return "sdm855";
    case "RMX2001":
      return "mt6785";
    default:
      return "qcom";
  }
}

String getUserAgent(
  String model,
  String releaseVersion,
  String fingerprint,
  String chromeVersion,
) {
  final id = fingerprint.split('/')[2].split(':')[1];
  return "Mozilla/5.0 (Linux; Android $releaseVersion; $model Build/$id; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/$chromeVersion Mobile Safari/537.36";
}

String generateFingerPrint(BaseDeviceInfo base) {
  String buildTag;
  switch (base.manufacturer.toLowerCase()) {
    case 'samsung':
      buildTag =
          "G${base.device.toUpperCase().substring(0, 3)}XXU${_random.nextInt(9)}X${_random.nextInt(1000).toString().padLeft(3, '0')}";
      break;
    case 'google':
      buildTag = "${_random.nextInt(9000000) + 1000000}";
      break;
    case 'xiaomi':
      buildTag =
          "V${_random.nextInt(12)}.${_random.nextInt(5)}.${_random.nextInt(5)}.0${_random.nextInt(1000).toString().padLeft(3, '0')}";
      break;
    default:
      buildTag =
          "${base.device.toUpperCase()}${_random.nextInt(1000).toString().padLeft(3, '0')}";
  }
  return "${base.brand}/${base.productName}/${base.device}:${base.releaseVersion}/${base.id}/$buildTag:user/release-keys";
}

String generateRandomMacAddress() {
  final List<int> mac = List.generate(6, (_) => _random.nextInt(256));
  mac[0] = (mac[0] & 0xFC) | 0x02; // Locally administered, unicast
  return mac
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(':');
}

String generateAndroidSerial() {
  const chars = '0123456789ABCDEF';
  return List.generate(16, (_) => chars[_random.nextInt(chars.length)]).join();
}

String generateSerialNumber(String manufacturer) {
  String prefix;
  int length;
  switch (manufacturer.toLowerCase()) {
    case 'samsung':
      prefix = 'R${_random.nextInt(9) + 1}';
      length = 11;
      break;
    case 'oneplus':
      prefix = 'OP';
      length = 10;
      break;
    case 'google':
      prefix = 'G';
      length = 10;
      break;
    case 'sony':
      prefix = 'FA${_random.nextInt(9)}';
      length = 12;
      break;
    case 'xiaomi':
    case 'poco':
      prefix = 'XM';
      length = 12;
      break;
    case 'huawei':
      prefix = 'HUA';
      length = 12;
      break;
    case 'motorola':
      prefix = 'MOTO';
      length = 12;
      break;
    case 'nokia':
      prefix = 'NOK';
      length = 12;
      break;
    case 'asus':
      prefix = 'ASUS';
      length = 12;
      break;
    case 'lg':
      prefix = 'LG';
      length = 12;
      break;
    case 'vivo':
      prefix = 'VIVO';
      length = 12;
      break;
    default:
      prefix = 'SN';
      length = 12;
  }
  const String chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String suffix = String.fromCharCodes(
    List.generate(
      length - prefix.length,
      (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
    ),
  );
  return prefix + suffix;
}

String generateAndroidId() {
  const chars = '0123456789abcdef';
  return String.fromCharCodes(
    Iterable.generate(
      16,
      (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
    ),
  );
}
String _randomHex(int length) {
  const hex = "0123456789abcdef";
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => hex.codeUnitAt(_random.nextInt(hex.length)),
    ),
  );
}

String generateAdvertisingId() {
  final hex = "0123456789abcdef";
  final y = ["8", "9", "a", "b"][_random.nextInt(4)];
  return "${_randomHex(8)}-${_randomHex(4)}-4${_randomHex(3)}-$y${_randomHex(3)}-${_randomHex(12)}";
}

String generateRandomImei(String manufacturer) {
  String tac;
  switch (manufacturer.toLowerCase()) {
    case 'xiaomi':
    case 'poco':
      tac = '86${_random.nextInt(999999).toString().padLeft(6, '0')}';
      break;
    case 'samsung':
      tac = '01${_random.nextInt(999999).toString().padLeft(6, '0')}';
      break;
    case 'google':
      tac = '35${_random.nextInt(999999).toString().padLeft(6, '0')}';
      break;
    default:
      tac = '35${_random.nextInt(999999).toString().padLeft(6, '0')}';
  }
  String serial = _random.nextInt(999999).toString().padLeft(6, '0');
  String baseImei = tac + serial;
  int checkDigit = calculateLuhnCheckDigit(baseImei);
  return baseImei + checkDigit.toString();
}

int calculateLuhnCheckDigit(String number) {
  int sum = 0;
  bool alternate = true;
  for (int i = number.length - 1; i >= 0; i--) {
    int digit = int.parse(number[i]);
    if (alternate) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
    alternate = !alternate;
  }
  return (10 - (sum % 10)) % 10;
}

Map<String, String> generateCountryData() {
  // Define country data with explicit types
  final List<Map<String, Object>> countryData = [
    // US
    {
      'countryIso': 'us',
      'mcc': '310',
      'mnc': <String>['170', '260', '410'],
      'operatorMapping': <String, String>{
        '170': 'T-Mobile',
        '260': 'T-Mobile',
        '410': 'AT&T',
      },
      'countryCode': '+1',
      'phoneLength': 10,
    },
    // GB
    {
      'countryIso': 'gb',
      'mcc': '234',
      'mnc': <String>['10', '15', '30'],
      'operatorMapping': <String, String>{
        '10': 'O2',
        '15': 'Vodafone',
        '30': 'EE',
      },
      'countryCode': '+44',
      'phoneLength': 11,
    },
    // China
    {
      'countryIso': 'cn',
      'mcc': '460',
      'mnc': <String>['00', '01', '02'],
      'operatorMapping': <String, String>{
        '00': 'China Mobile',
        '01': 'China Unicom',
        '02': 'China Telecom',
      },
      'countryCode': '+86',
      'phoneLength': 11,
    },
    // India (primary market for Mi A1)
    {
      'countryIso': 'in',
      'mcc': '404',
      'mnc': <String>['10', '01', '855'],
      'operatorMapping': <String, String>{
        '10': 'Airtel',
        '01': 'Vodafone Idea',
        '855': 'Jio',
      },
      'countryCode': '+91',
      'phoneLength': 10,
    },
    // Japan
    {
      'countryIso': 'jp',
      'mcc': '440',
      'mnc': <String>['10', '20', '30'],
      'operatorMapping': <String, String>{
        '10': 'NTT Docomo',
        '20': 'SoftBank',
        '30': 'au',
      },
      'countryCode': '+81',
      'phoneLength': 10,
    },
  ];

  // Bias toward India (~33% chance)
  final List<Map<String, Object>> weightedCountries = [
    countryData[3], // India
    countryData[3], // India
    countryData[0], // US
    countryData[1], // GB
    countryData[2], // CN
    countryData[4], // JP
  ];

  // Select random country
  final Map<String, Object> data = weightedCountries[_random.nextInt(weightedCountries.length)];

  // Safely extract fields
  final String countryIso = data['countryIso'] as String;
  final String mcc = data['mcc'] as String;
  final List<String> mncList = data['mnc'] as List<String>;
  final Map<String, String> operatorMapping = data['operatorMapping'] as Map<String, String>;
  final String countryCode = data['countryCode'] as String;
  final int phoneLength = data['phoneLength'] as int;

  // Select random MNC
  final String mnc = mncList.isNotEmpty ? mncList[_random.nextInt(mncList.length)] : '00';

  // Get operator name (fallback to generic if MNC not found)
  final String operatorName = operatorMapping[mnc] ?? 'Unknown Carrier';

  // Generate phone number
  final int digitLength = phoneLength - countryCode.length;
  final String phoneDigits = digitLength > 0
      ? List.generate(digitLength, (_) => _random.nextInt(10).toString()).join()
      : '';
  final String phoneNumber = '$countryCode$phoneDigits';

  return {
    'countryIso': countryIso,
    'mcc': mcc,
    'operator': '$mcc$mnc',
    'operatorName': operatorName,
    'phoneNumber': phoneNumber,
  };
}

String generateSubscriberId(String mcc) {
  final countryData = {
    '310': ['150', '170', '260', '410'],
    '234': ['10', '15', '30'],
    '460': ['00', '01', '02'],
    '404': ['10', '20', '30'],
    '440': ['10', '20', '30'],
  };
  final mnc = countryData[mcc]![_random.nextInt(countryData[mcc]!.length)];
  final msin = List.generate(9, (_) => _random.nextInt(10).toString()).join();
  return '$mcc$mnc$msin';
}

String generatePhoneNumber() {
  final countryCode = ['+1', '+44', '+86', '+91'].elementAt(_random.nextInt(4));
  final areaCode = _random.nextInt(900) + 100;
  final subscriber =
      List.generate(7, (_) => _random.nextInt(10).toString()).join();
  return '$countryCode$areaCode$subscriber';
}

String generateHost() {
  final servers = ['build-server', 'compile-host', 'ci-node', 'jenkins', 'dev-host'];
  final number = _random.nextInt(100).toString().padLeft(2, '0');
  return '${servers[_random.nextInt(servers.length)]}-$number';
}

String generateSerialSimNumber(String mcc) {
  final iccidPrefixes = {
    '310': '891480',
    '234': '894410',
    '460': '898600',
    '404': '899100',
    '440': '898110',
  };
  final prefix = iccidPrefixes[mcc] ?? '8901260';
  final serial = List.generate(12, (_) => _random.nextInt(10).toString()).join();
  final baseIccid = prefix + serial;
  final checksum = calculateLuhnCheckDigit(baseIccid);
  return '$baseIccid$checksum';
}

String generateBssid() {
  return List.generate(
    6,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase(),
  ).join(':');
}

String generateOperator() {
  final mcc = ['310', '311', '312'].elementAt(_random.nextInt(3));
  final mnc = ['260', '150', '170'].elementAt(_random.nextInt(3));
  return '$mcc$mnc';
}

String generateOperatorName() {
  final operators = ['Verizon', 'AT&T', 'T-Mobile', 'Vodafone', 'O2'];
  return operators[_random.nextInt(operators.length)];
}

String generateWifiIp() {
  final subnets = ['192.168.1', '192.168.0', '10.0.0'];
  final subnet = subnets[_random.nextInt(subnets.length)];
  final lastOctet = _random.nextInt(200) + 50;
  return '$subnet.$lastOctet';
}

String generateCountryIso() {
  final countries = ['us', 'gb', 'cn', 'in', 'de'];
  return countries[_random.nextInt(countries.length)];
}

final List<BaseDeviceInfo> baseDeviceInfoList = [
  // 1. Xiaomi Redmi Note 7
  BaseDeviceInfo(
    model: "Redmi Note 7",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    device: "lavender",
    productName: "lavender",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2340,
    glVendor: "Qualcomm",
    glRender: "Adreno 512",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm660",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.190910.002",
    display: "QKQ1.190910.002",
  ),

  // 2. Xiaomi Mi 8 Lite
  BaseDeviceInfo(
    model: "Mi 8 Lite",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    device: "platina",
    productName: "platina",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2280,
    glVendor: "Qualcomm",
    glRender: "Adreno 616",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm660",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.190910.002",
    display: "QKQ1.190910.002",
  ),

  // 3. Xiaomi Redmi 8
  BaseDeviceInfo(
    model: "Redmi 8",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    device: "olive",
    productName: "olive",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 720,
    height: 1520,
    glVendor: "Qualcomm",
    glRender: "Adreno 505",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm439",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.191008.001",
    display: "QKQ1.191008.001",
  ),

  // 4. Samsung Galaxy A50
  BaseDeviceInfo(
    model: "SM-A505F",
    brand: "Samsung",
    manufacturer: "Samsung",
    device: "a50",
    productName: "a50",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2340,
    glVendor: "ARM",
    glRender: "Mali-G72 MP3",
    hardware: "exynos9611",
    radio: "1.0.0",
    bootloader: "u1.0.0",
    board: "exynos9611",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QP1A.190711.020",
    display: "QP1A.190711.020",
  ),

  // 5. Samsung Galaxy M31
  BaseDeviceInfo(
    model: "SM-M315F",
    brand: "Samsung",
    manufacturer: "Samsung",
    device: "m31",
    productName: "m31",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2340,
    glVendor: "ARM",
    glRender: "Mali-G72 MP3",
    hardware: "exynos9611",
    radio: "1.0.0",
    bootloader: "u1.0.0",
    board: "exynos9611",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QP1A.190711.020",
    display: "QP1A.190711.020",
  ),

  // 6. Samsung Galaxy S9
  BaseDeviceInfo(
    model: "SM-G960F",
    brand: "Samsung",
    manufacturer: "Samsung",
    device: "starlte",
    productName: "starlte",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1440,
    height: 2960,
    glVendor: "ARM",
    glRender: "Mali-G72 MP18",
    hardware: "exynos9810",
    radio: "1.0.0",
    bootloader: "u1.0.0",
    board: "exynos9810",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QP1A.190711.020",
    display: "QP1A.190711.020",
  ),

  // 7. OnePlus 6T
  BaseDeviceInfo(
    model: "A6010",
    brand: "OnePlus",
    manufacturer: "OnePlus",
    device: "OnePlus6T",
    productName: "OnePlus6T",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2340,
    glVendor: "Qualcomm",
    glRender: "Adreno 630",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm845",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.190716.003",
    display: "QKQ1.190716.003",
  ),

  // 8. OnePlus Nord
  BaseDeviceInfo(
    model: "AC2003",
    brand: "OnePlus",
    manufacturer: "OnePlus",
    device: "avicii",
    productName: "avicii",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2400,
    glVendor: "Qualcomm",
    glRender: "Adreno 620",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm765",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.200114.002",
    display: "QKQ1.200114.002",
  ),

  // 9. Google Pixel 3
  BaseDeviceInfo(
    model: "Pixel 3",
    brand: "Google",
    manufacturer: "Google",
    device: "blueline",
    productName: "blueline",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2160,
    glVendor: "Qualcomm",
    glRender: "Adreno 630",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm845",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QP1A.191005.007",
    display: "QP1A.191005.007",
  ),

  // 10. Google Pixel 4a
  BaseDeviceInfo(
    model: "Pixel 4a",
    brand: "Google",
    manufacturer: "Google",
    device: "sunfish",
    productName: "sunfish",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2340,
    glVendor: "Qualcomm",
    glRender: "Adreno 618",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm730",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QD1A.200317.002",
    display: "QD1A.200317.002",
  ),

  // 11. Sony Xperia 10 II
  BaseDeviceInfo(
    model: "XQ-AU52",
    brand: "Sony",
    manufacturer: "Sony",
    device: "XQ-AU52",
    productName: "XQ-AU52",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2520,
    glVendor: "Qualcomm",
    glRender: "Adreno 610",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm665",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "59.1.A.3.49",
    display: "59.1.A.3.49",
  ),

  // 12. Sony Xperia 5
  BaseDeviceInfo(
    model: "J8210",
    brand: "Sony",
    manufacturer: "Sony",
    device: "J8210",
    productName: "J8210",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2520,
    glVendor: "Qualcomm",
    glRender: "Adreno 640",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm855",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "55.1.A.3.49",
    display: "55.1.A.3.49",
  ),

  // 13. Oppo A72
  BaseDeviceInfo(
    model: "CPH2067",
    brand: "Oppo",
    manufacturer: "Oppo",
    device: "CPH2067",
    productName: "CPH2067",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2400,
    glVendor: "Qualcomm",
    glRender: "Adreno 610",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm665",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.200209.002",
    display: "QKQ1.200209.002",
  ),

  // 14. Realme 6
  BaseDeviceInfo(
    model: "RMX2001",
    brand: "Realme",
    manufacturer: "Realme",
    device: "RMX2001",
    productName: "RMX2001",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2400,
    glVendor: "ARM",
    glRender: "Mali-G76 MC4",
    hardware: "mediatek",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "mt6785",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.200209.002",
    display: "QKQ1.200209.002",
  ),

  // 15. Huawei P30 Lite
  BaseDeviceInfo(
    model: "MAR-LX1A",
    brand: "Huawei",
    manufacturer: "Huawei",
    device: "marie",
    productName: "marie",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2312,
    glVendor: "ARM",
    glRender: "Mali-G51 MP4",
    hardware: "kirin710",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "kirin710",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.190828.001",
    display: "QKQ1.190828.001",
  ),

  // 16. Motorola Moto G8 Power
  BaseDeviceInfo(
    model: "XT2041-1",
    brand: "Motorola",
    manufacturer: "Motorola",
    device: "sofia",
    productName: "sofia",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2300,
    glVendor: "Qualcomm",
    glRender: "Adreno 610",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm665",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QP1A.190711.020",
    display: "QP1A.190711.020",
  ),

  // 17. Nokia 7.2
  BaseDeviceInfo(
    model: "TA-1198",
    brand: "Nokia",
    manufacturer: "HMD Global",
    device: "Daredevil",
    productName: "Daredevil",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2340,
    glVendor: "Qualcomm",
    glRender: "Adreno 618",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm660",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.190915.001",
    display: "QKQ1.190915.001",
  ),

  // 18. Asus Zenfone 6
  BaseDeviceInfo(
    model: "ZS630KL",
    brand: "Asus",
    manufacturer: "Asus",
    device: "I01WD",
    productName: "I01WD",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2340,
    glVendor: "Qualcomm",
    glRender: "Adreno 640",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm855",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.190814.001",
    display: "QKQ1.190814.001",
  ),

  // 19. LG G8 ThinQ
  BaseDeviceInfo(
    model: "LM-G820",
    brand: "LG",
    manufacturer: "LG",
    device: "alpha",
    productName: "alpha",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1440,
    height: 3120,
    glVendor: "Qualcomm",
    glRender: "Adreno 640",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm855",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.190910.001",
    display: "QKQ1.190910.001",
  ),

  // 20. Vivo V17
  BaseDeviceInfo(
    model: "V1945A",
    brand: "Vivo",
    manufacturer: "Vivo",
    device: "PD1948F",
    productName: "PD1948F",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2400,
    glVendor: "Qualcomm",
    glRender: "Adreno 618",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm675",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.191008.001",
    display: "QKQ1.191008.001",
  ),

  // 21. Poco X3 NFC
  BaseDeviceInfo(
    model: "M2007J20CG",
    brand: "Poco",
    manufacturer: "Xiaomi",
    device: "surya",
    productName: "surya",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2400,
    glVendor: "Qualcomm",
    glRender: "Adreno 619",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm732G",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QKQ1.200614.002",
    display: "QKQ1.200614.002",
  ),

  // 22. Samsung Galaxy Note 10
  BaseDeviceInfo(
    model: "SM-N970F",
    brand: "Samsung",
    manufacturer: "Samsung",
    device: "d1",
    productName: "d1",
    releaseVersion: "10",
    sdkVersion: "29",
    width: 1080,
    height: 2280,
    glVendor: "ARM",
    glRender: "Mali-G76 MP12",
    hardware: "exynos9825",
    radio: "1.0.0",
    bootloader: "u1.0.0",
    board: "exynos9825",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "83.0.4103.106",
    id: "QP1A.190711.020",
    display: "QP1A.190711.020",
  ),

  // 24. OnePlus 8
  BaseDeviceInfo(
    model: "IN2013",
    brand: "OnePlus",
    manufacturer: "OnePlus",
    device: "instantnoodle",
    productName: "instantnoodle",
    releaseVersion: "11",
    sdkVersion: "30",
    width: 1080,
    height: 2400,
    glVendor: "Qualcomm",
    glRender: "Adreno 650",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm865",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "86.0.4240.198",
    id: "RKQ1.201105.002",
    display: "RKQ1.201105.002",
  ),

  // 25. Xiaomi Mi 10
  BaseDeviceInfo(
    model: "M2001J2G",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    device: "umi",
    productName: "umi",
    releaseVersion: "11",
    sdkVersion: "30",
    width: 1080,
    height: 2400,
    glVendor: "Qualcomm",
    glRender: "Adreno 650",
    hardware: "qcom",
    radio: "1.0.0",
    bootloader: "b1.0.0",
    board: "sdm865",
    codename: "REL",
    macHardware: "wlan0",
    versionChrome: "86.0.4240.198",
    id: "RKQ1.200826.002",
    display: "RKQ1.200826.002",
  ),
];
