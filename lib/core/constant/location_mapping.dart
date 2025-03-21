final Map<String, List<Map<String, double>>> timezoneCoordinates = {
  "us": [
    // America/New_York (Eastern Time Zone, USA)
    {"lat": 40.7128, "lon": -74.0060}, // New York City
    {"lat": 38.9072, "lon": -77.0369}, // Washington, D.C.
    {"lat": 25.7617, "lon": -80.1918}, // Miami
  ],
  "ca": [
    // America/Toronto (Eastern Time Zone, Canada)
    {"lat": 43.6511, "lon": -79.3832}, // Toronto
    {"lat": 45.4215, "lon": -75.6972}, // Ottawa
    {"lat": 42.9849, "lon": -81.2453}, // London, ON
  ],
  "uk": [
    // Europe/London (GMT/BST)
    {"lat": 51.5074, "lon": -0.1278}, // London
    {"lat": 53.4830, "lon": -2.2443}, // Manchester
    {"lat": 55.9533, "lon": -3.1883}, // Edinburgh
  ],
  "au": [
    // Australia/Sydney (AEDT)
    {"lat": -33.8688, "lon": 151.2093}, // Sydney
    {"lat": -35.2809, "lon": 149.1300}, // Canberra
    {"lat": -36.8509, "lon": 174.7645}, // Melbourne (approx)
  ],
  "in": [
    // Asia/Kolkata (IST)
    {"lat": 28.6139, "lon": 77.2090}, // New Delhi
    {"lat": 19.0760, "lon": 72.8777}, // Mumbai
    {"lat": 13.0827, "lon": 80.2707}, // Chennai
  ],
  "jp": [
    // Asia/Tokyo (JST)
    {"lat": 35.6762, "lon": 139.6503}, // Tokyo
    {"lat": 34.6937, "lon": 135.5023}, // Osaka
    {"lat": 43.0618, "lon": 141.3545}, // Sapporo
  ],
  "cn": [
    // Asia/Shanghai (CST)
    {"lat": 31.2304, "lon": 121.4737}, // Shanghai
    {"lat": 39.9042, "lon": 116.4074}, // Beijing
    {"lat": 23.1291, "lon": 113.2644}, // Guangzhou
  ],
  "kr": [
    // Asia/Seoul (KST)
    {"lat": 37.5665, "lon": 126.9780}, // Seoul
    {"lat": 35.1796, "lon": 129.0756}, // Busan
    {"lat": 36.3504, "lon": 127.3845}, // Daejeon
  ],
  "ru": [
    // Europe/Moscow (MSK)
    {"lat": 55.7558, "lon": 37.6173}, // Moscow
    {"lat": 59.9343, "lon": 30.3351}, // Saint Petersburg
    {"lat": 54.7388, "lon": 20.4835}, // Kaliningrad (technically MSK-1)
  ],
  "de": [
    // Europe/Berlin (CET/CEST)
    {"lat": 52.5200, "lon": 13.4050}, // Berlin
    {"lat": 48.1351, "lon": 11.5820}, // Munich
    {"lat": 50.9375, "lon": 6.9603}, // Cologne
  ],
  "fr": [
    // Europe/Paris (CET/CEST)
    {"lat": 48.8566, "lon": 2.3522}, // Paris
    {"lat": 45.7640, "lon": 4.8357}, // Lyon
    {"lat": 43.2965, "lon": 5.3698}, // Marseille
  ],
  "it": [
    // Europe/Rome (CET/CEST)
    {"lat": 41.9028, "lon": 12.4964}, // Rome
    {"lat": 45.4642, "lon": 9.1900}, // Milan
    {"lat": 40.8518, "lon": 14.2681}, // Naples
  ],
  "es": [
    // Europe/Madrid (CET/CEST)
    {"lat": 40.4168, "lon": -3.7038}, // Madrid
    {"lat": 41.3851, "lon": 2.1734}, // Barcelona
    {"lat": 37.3891, "lon": -5.9845}, // Seville
  ],
  "br": [
    // America/Sao_Paulo (BRT)
    {"lat": -23.5505, "lon": -46.6333}, // São Paulo
    {"lat": -22.9068, "lon": -43.1729}, // Rio de Janeiro
    {"lat": -15.7942, "lon": -47.8825}, // Brasília
  ],
  "mx": [
    // America/Mexico_City (CST)
    {"lat": 19.4326, "lon": -99.1332}, // Mexico City
    {"lat": 20.6767, "lon": -103.3475}, // Guadalajara
    {"lat": 25.6866, "lon": -100.3161}, // Monterrey
  ],
  "za": [
    // Africa/Johannesburg (SAST)
    {"lat": -26.2041, "lon": 28.0473}, // Johannesburg
    {"lat": -33.9249, "lon": 18.4241}, // Cape Town
    {"lat": -29.8587, "lon": 31.0218}, // Durban
  ],
  "eg": [
    // Africa/Cairo (EET)
    {"lat": 30.0444, "lon": 31.2357}, // Cairo
    {"lat": 31.2001, "lon": 29.9187}, // Alexandria
    {"lat": 26.8206, "lon": 30.8025}, // Luxor
  ],
  "tr": [
    // Europe/Istanbul (TRT)
    {"lat": 41.0082, "lon": 28.9784}, // Istanbul
    {"lat": 39.9334, "lon": 32.8597}, // Ankara
    {"lat": 38.4237, "lon": 27.1428}, // Izmir
  ],
  "sa": [
    // Asia/Riyadh (AST)
    {"lat": 24.7136, "lon": 46.6753}, // Riyadh
    {"lat": 21.5433, "lon": 39.1728}, // Jeddah
    {"lat": 26.4207, "lon": 50.0888}, // Dammam
  ],
  "ae": [
    // Asia/Dubai (GST)
    {"lat": 25.2048, "lon": 55.2708}, // Dubai
    {"lat": 24.4539, "lon": 54.3773}, // Abu Dhabi
    {"lat": 25.4052, "lon": 55.5136}, // Sharjah
  ],
  "id": [
    // Asia/Jakarta (WIB)
    {"lat": -6.2088, "lon": 106.8456}, // Jakarta
    {"lat": -7.2575, "lon": 112.7521}, // Surabaya
    {"lat": -6.9175, "lon": 107.6191}, // Bandung
  ],
  "vn": [
    // Asia/Ho_Chi_Minh (ICT)
    {"lat": 10.7769, "lon": 106.7009}, // Ho Chi Minh City
    {"lat": 21.0278, "lon": 105.8342}, // Hanoi
    {"lat": 16.0544, "lon": 108.2022}, // Da Nang
  ],
  "th": [
    // Asia/Bangkok (ICT)
    {"lat": 13.7563, "lon": 100.5018}, // Bangkok
    {"lat": 18.7883, "lon": 98.9853}, // Chiang Mai
    {"lat": 7.8804, "lon": 98.3923}, // Phuket
  ],
  "my": [
    // Asia/Kuala_Lumpur (MYT)
    {"lat": 3.1390, "lon": 101.6869}, // Kuala Lumpur
    {"lat": 5.4164, "lon": 100.3327}, // George Town, Penang
    {"lat": 1.5533, "lon": 110.3592}, // Kuching
  ],
  "sg": [
    // Asia/Singapore (SGT)
    {"lat": 1.3521, "lon": 103.8198}, // Singapore (central)
    {"lat": 1.4506, "lon": 103.8210}, // Woodlands
    {"lat": 1.2903, "lon": 103.8499}, // Marina Bay
  ],
  "ph": [
    // Asia/Manila (PHT)
    {"lat": 14.5995, "lon": 120.9842}, // Manila
    {"lat": 10.3157, "lon": 123.8854}, // Cebu City
    {"lat": 7.0731, "lon": 125.6128}, // Davao City
  ],
  "ar": [
    // America/Argentina/Buenos_Aires (ART)
    {"lat": -34.6037, "lon": -58.3816}, // Buenos Aires
    {"lat": -31.4201, "lon": -64.1888}, // Córdoba
    {"lat": -32.8895, "lon": -68.8458}, // Mendoza
  ],
  "cl": [
    // America/Santiago (CLT)
    {"lat": -33.4489, "lon": -70.6693}, // Santiago
    {"lat": -36.8270, "lon": -73.0503}, // Concepción
    {"lat": -23.6524, "lon": -70.3954}, // Antofagasta
  ],
  "nz": [
    // Pacific/Auckland (NZDT)
    {"lat": -36.8485, "lon": 174.7633}, // Auckland
    {"lat": -41.2865, "lon": 174.7762}, // Wellington
    {"lat": -43.5320, "lon": 172.6362}, // Christchurch
  ],
  "pk": [
    // Asia/Karachi (PKT)
    {"lat": 24.8607, "lon": 67.0011}, // Karachi
    {"lat": 31.5497, "lon": 74.3436}, // Lahore
    {"lat": 33.6844, "lon": 73.0479}, // Islamabad
  ],
  "bd": [
    // Asia/Dhaka (BDT)
    {"lat": 23.8103, "lon": 90.4125}, // Dhaka
    {"lat": 22.3569, "lon": 91.7832}, // Chittagong
    {"lat": 24.8949, "lon": 91.8687}, // Sylhet
  ],
  "ng": [
    // Africa/Lagos (WAT)
    {"lat": 6.5244, "lon": 3.3792}, // Lagos
    {"lat": 9.0579, "lon": 7.4951}, // Abuja
    {"lat": 4.9757, "lon": 8.3417}, // Calabar
  ],
  "ke": [
    // Africa/Nairobi (EAT)
    {"lat": -1.2921, "lon": 36.8219}, // Nairobi
    {"lat": -4.0435, "lon": 39.6682}, // Mombasa
    {"lat": 0.0917, "lon": 34.7679}, // Kisumu
  ],
};
