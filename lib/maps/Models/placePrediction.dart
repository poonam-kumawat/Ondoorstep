class PlacePrediction {
  late String secondary_text;
  late String main_text;
  late String place_id;
  PlacePrediction(
      {required this.main_text,
      required this.place_id,
      required this.secondary_text});
  PlacePrediction.fromJson(Map<String, dynamic> json) {
    main_text = json['structured_formatting']['main_text'];
    secondary_text = json['structured_formatting']['secondary_text'];
    place_id = json['place_id'];
  }
}
