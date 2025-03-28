class Message {
  Message({
    required this.toId,
    required this.msg,
    required this.formId,
    required this.read,
    required this.type,
    required this.sent,
  });
  late final String toId;
  late final String msg;
  late final String formId;
  late final String read;
  late final String sent;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    formId = json['formId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['formId'] = formId;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
