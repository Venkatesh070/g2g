class GooglePlacesBean {
  List<Predictions>? predictions;
  String? status;

  GooglePlacesBean({this.predictions, this.status});

  GooglePlacesBean.fromJson(Map<String, dynamic> json) {
    if (json['predictions'] != null) {
      predictions = <Predictions>[];
      json['predictions'].forEach((v) {
        predictions!.add(new Predictions.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.predictions != null) {
      data['predictions'] = this.predictions!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class Predictions {
  String? description;


  Predictions(
      {this.description,
   });

  Predictions.fromJson(Map<String, dynamic> json) {
    description = json['description'] ?? "";

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description ?? "";

    return data;
  }
}



