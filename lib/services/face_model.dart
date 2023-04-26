class FaceData {
  String? name;
  String? img;

  FaceData({this.name, this.img});

  FaceData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['img'] = img;
    return data;
  }
}