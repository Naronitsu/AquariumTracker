class WaterParameters {
  double ph;
  double nitrate;
  double nitrite;
  double ammonia;
  double generalHardness;
  double temperature;

  WaterParameters({
    required this.ph,
    required this.nitrate,
    required this.nitrite,
    required this.ammonia,
    required this.generalHardness,
    required this.temperature,
  });

bool isPhUnsafe(double value) => value < 6.0 || value > 8.0;
bool isNitrateUnsafe(double value) => value > 40;
bool isNitriteUnsafe(double value) => value > 1;
bool isAmmoniaUnsafe(double value) => value > 0.25;
bool isGhUnsafe(double value) => value < 4 || value > 12;
bool isTempUnsafe(double value) => value < 22 || value > 28;

}
