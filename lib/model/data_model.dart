class ModelApp {
  int? id;
  String? title;
  double? price;
  String? description;
  String? category;
  String? image;
  double? rating;

  ModelApp(
      {this.id,
      this.title,
      this.price,
      this.description,
      this.category,
      this.image,
      this.rating});

  ModelApp.fromJson(Map<String, dynamic> json) {
  id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
  title = json['title'];
  price = (json['price'] as num).toDouble();
  description = json['description'];
  category = json['category'];
  image = json['image'];
  rating = (json['rating'] as num).toDouble();
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['description'] = description;
    data['category'] = category;
    data['image'] = image;
    data['rating'] = rating;
    return data;
  }
}
