import 'dart:convert';

class ErrorAnswer {
  final String? detail;
  final String? locString;
  final int? locNumber;
  final String? msg;
  final String? type;

  ErrorAnswer(
      {this.detail, this.locString, this.locNumber, this.msg, this.type});

  factory ErrorAnswer.fromJson(Map<String, dynamic> json) {
    var detailsList = json['detail'];
    var jsonErr = detailsList[0].runtimeType == String ? {} : detailsList[0];
    var locList = jsonErr['loc'] ?? [null, null];
    return ErrorAnswer(
      detail: detailsList.runtimeType == String ? detailsList : null,
      locString: locList[0],
      locNumber: locList[1],
      msg: jsonErr['msg'],
      type: jsonErr['type'],
    );
  }
}

void parseJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  if (jsonData.containsKey('detail')) {
    var detailList = jsonData['detail'];
    for (var item in detailList) {
      ErrorAnswer errorAnswer = ErrorAnswer.fromJson(item);
    }
  }
}
