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

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "fname": fname,
      "lname": lname,
      "email": email,
      "isAdmin": isAdmin,
    };
  }

  @override
  String toString() {
    return "User{username: $username, fname: $fname, lname: $lname, email: "
        "$email, isAdmin: $isAdmin}";
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

  Map<String, dynamic> toJson() {
    return {
      "userEventId": userEventId,
      "userId": userId,
      "eventId": eventId,
      "isAttended": isAttended,
      "broughtPlusOne": broughtPlusOne,
      "waiverSigned": waiverSigned,
    };
  }

  @override
  String toString() {
    return "UserEvent{userEventId: $userEventId, userId: $userId, eventId: "
        "$eventId, isAttended: $isAttended, broughtPlusOne: $broughtPlusOne, "
        "waiverSigned: $waiverSigned}";
  }
}

class Event {
  String eventId;
  String eventDescription;
  String eventTitle;
  String eventLocation;
  String eventInfo;
  DateTime eventStartTime;
  DateTime eventEndTime;

  Event({
    required this.eventId,
    required this.eventDescription,
    required this.eventTitle,
    required this.eventLocation,
    required this.eventInfo,
    required this.eventStartTime,
    required this.eventEndTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      eventDescription: json['eventDescription'],
      eventTitle: json['eventTitle'],
      eventLocation: json['eventLocation'],
      eventStartTime: json['eventStartTime'],
      eventEndTime: json['eventEndTime'],
      eventInfo: json['eventInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventId": eventId,
      "eventDescription": eventDescription,
      "eventTitle": eventTitle,
      "eventLocation": eventLocation,
      "eventStartTime": eventStartTime,
      "eventEndTime": eventEndTime,
      "eventInfo": eventInfo,
    };
  }

  @override
  String toString() {
    return "Event{eventId: $eventId, eventDescription: $eventDescription, "
        "eventTitle: $eventTitle, eventLocation: $eventLocation, eventStartTime:"
        " $eventStartTime, eventEndTime: $eventEndTime, eventInfo: $eventInfo}";
  }
}

class EventItem {
  String eventItemId;
  String eventItemTitle;
  String eventItemLocation;
  String eventItemInfo;
  String eventId;
  DateTime eventItemStartTime;
  DateTime eventItemEndTime;
  String eventItemType;
  String password;
  String waiver;

  EventItem({
    required this.eventItemId,
    required this.eventItemTitle,
    required this.eventItemLocation,
    required this.eventItemInfo,
    required this.eventId,
    required this.eventItemStartTime,
    required this.eventItemEndTime,
    required this.eventItemType,
    required this.password,
    required this.waiver,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      eventItemId: json['eventItemId'],
      eventItemTitle: json['eventItemTitle'],
      eventItemLocation: json['eventItemLocation'],
      eventItemInfo: json['eventItemInfo'],
      eventId: json['eventId'],
      eventItemStartTime: json['itemStartTime'],
      eventItemEndTime: json['itemEndTime'],
      eventItemType: json['eventItemType'],
      password: json['password'],
      waiver: json['waiver'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventItemId": eventItemId,
      "eventItemTitle": eventItemTitle,
      "eventItemLocation": eventItemLocation,
      "eventItemInfo": eventItemInfo,
      "eventId": eventId,
      "itemStartTime": eventItemStartTime,
      "itemEndTime": eventItemEndTime,
      "eventItemType": eventItemType,
      "password": password,
      "waiver": waiver,
    };
  }

  @override
  String toString() {
    return "EventItem{eventItemId: $eventItemId, eventItemTitle: "
        "$eventItemTitle, eventItemLocation: $eventItemLocation, eventItemInfo: "
        "$eventItemInfo, eventId: $eventId, itemStartTime: $eventItemStartTime, "
        "itemEndTime: $eventItemEndTime, eventItemType: $eventItemType, "
        "password: $password, waiver: $waiver}";
  }
}

class EventItemType {
  String eventItemTypeId;
  String typeName;

  EventItemType({
    required this.eventItemTypeId,
    required this.typeName,
  });

  factory EventItemType.fromJson(Map<String, dynamic> json) {
    return EventItemType(
      eventItemTypeId: json['eventItemTypeId'],
      typeName: json['typeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "eventItemTypeId": eventItemTypeId,
      "typeName": typeName,
    };
  }

  @override
  String toString() {
    return "EventType{eventItemTypeId: $eventItemTypeId, typeName: $typeName}";
  }
}
