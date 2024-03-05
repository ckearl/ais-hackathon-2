class User {
  String username;
  String fname;
  String lname;
  String email;
  bool isAdmin;

  User({
    required this.username,
    required this.fname,
    required this.lname,
    required this.email,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      fname: json['fname'],
      lname: json['lname'],
      email: json['email'],
      isAdmin: json['isAdmin'],
    );
  }
}

class UserEvent {
  String userEventId;
  String userId;
  String eventId;
  bool isAttended;
  bool broughtPlusOne;
  bool waiverSigned;

  UserEvent({
    required this.userEventId,
    required this.userId,
    required this.eventId,
    required this.isAttended,
    required this.broughtPlusOne,
    required this.waiverSigned,
  });

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      userEventId: json['userEventId'],
      userId: json['userId'],
      eventId: json['eventId'],
      isAttended: json['isAttended'],
      broughtPlusOne: json['broughtPlusOne'],
      waiverSigned: json['waiverSigned'],
    );
  }
}

class Event {
  String eventId;
  int eventDescriptionId;
  int eventTypeId;
  String eventTitle;
  String eventLocation;
  String eventInfo;

  Event({
    required this.eventId,
    required this.eventDescriptionId,
    required this.eventTypeId,
    required this.eventTitle,
    required this.eventLocation,
    required this.eventInfo,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      eventDescriptionId: json['eventDescriptionId'],
      eventTypeId: json['eventTypeId'],
      eventTitle: json['eventTitle'],
      eventLocation: json['eventLocation'],
      eventInfo: json['eventInfo'],
    );
  }
}

class EventItem {
  String eventItemId;
  String eventItemTitle;
  String eventItemLocation;
  String eventItemInfo;
  String eventId;
  String itemStartTime;
  String itemEndTime;
  String waiver;

  EventItem({
    required this.eventItemId,
    required this.eventItemTitle,
    required this.eventItemLocation,
    required this.eventItemInfo,
    required this.eventId,
    required this.itemStartTime,
    required this.itemEndTime,
    required this.waiver,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      eventItemId: json['eventItemId'],
      eventItemTitle: json['eventItemTitle'],
      eventItemLocation: json['eventItemLocation'],
      eventItemInfo: json['eventItemInfo'],
      eventId: json['eventId'],
      itemStartTime: json['itemStartTime'],
      itemEndTime: json['itemEndTime'],
      waiver: json['waiver'],
    );
  }
}

class EventType {
  String eventTypeId;
  String typeName;

  EventType({
    required this.eventTypeId,
    required this.typeName,
  });

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      eventTypeId: json['eventTypeId'],
      typeName: json['typeName'],
    );
  }
}
