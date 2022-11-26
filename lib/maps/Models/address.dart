class Address {
  String placeFormattedAddress = ' ';
  String placeName = '';
  String placeId = '';
  double latitude = 0.0;
  double longitude = 0.0;
  Address(
      {required this.placeFormattedAddress,
      required this.placeId,
      required this.placeName,
      required this.latitude,
      required this.longitude});
}
