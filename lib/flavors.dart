enum Flavor{
  DEV,
  PROD
}
const flavor =  String.fromEnvironment("FLAVOR", defaultValue: "dev") == "dev" ?Flavor.DEV : Flavor.PROD;
