class Meta {
  final int code;
  final String message;

  Meta({required this.code, required this.message});

  factory Meta.fromJson(Map<String, dynamic> json) =>
      Meta(code: json['code'] as int, message: json['message'] as String);
}

class SessionInfo {
  final int remainingSeconds;
  SessionInfo({required this.remainingSeconds});
  factory SessionInfo.fromJson(Map<String, dynamic> json) =>
      SessionInfo(remainingSeconds: json['remainingSeconds'] as int);
}

class Names {
  final String id;
  final String? formatted;
  final String familyName;
  final String givenName;
  final String? middleName;
  final String? honorificPrefix;
  final String? honorificSuffix;

  Names({
    required this.id,
    required this.formatted,
    required this.familyName,
    required this.givenName,
    required this.middleName,
    required this.honorificPrefix,
    required this.honorificSuffix,
  });

  factory Names.fromJson(Map<String, dynamic> json) => Names(
        id: json['id'] as String,
        formatted: json['formatted'] as String?,
        familyName: json['familyName'] as String,
        givenName: json['givenName'] as String,
        middleName: json['middleName'] as String?,
        honorificPrefix: json['honorificPrefix'] as String?,
        honorificSuffix: json['honorificSuffix'] as String?,
      );
}

class Photo {
  final String id;
  final String value;
  final String type;
  Photo({required this.id, required this.value, required this.type});
  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'] as String,
        value: json['value'] as String,
        type: json['type'] as String,
      );
}

class Email {
  final String id;
  final String value;
  final String? type;
  Email({required this.id, required this.value, required this.type});
  factory Email.fromJson(Map<String, dynamic> json) => Email(
        id: json['id'] as String,
        value: json['value'] as String,
        type: json['type'] as String?,
      );
}

class Verification {
  final String id;
  final String email;
  final bool verified;
  final String createdAt;
  final String updatedAt;
  Verification({
    required this.id,
    required this.email,
    required this.verified,
    required this.createdAt,
    required this.updatedAt,
  });
  factory Verification.fromJson(Map<String, dynamic> json) => Verification(
        id: json['id'] as String,
        email: json['email'] as String,
        verified: json['verified'] as bool,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}

class UserInfo {
  final String id;
  final String externalId;
  final String userName;
  final String displayName;
  final String? nickName;
  final String? profileUrl;
  final String? title;
  final String? userType;
  final String? preferredLanguage;
  final String locale;
  final String? timezone;
  final bool active;
  final Names names;
  final List<Photo> photos;
  final List<dynamic> phoneNumbers;
  final List<dynamic> addresses;
  final List<Email> emails;
  final List<Verification> verifications;
  final String provider;
  final String createdAt;
  final String updatedAt;
  final String environmentId;

  UserInfo({
    required this.id,
    required this.externalId,
    required this.userName,
    required this.displayName,
    required this.nickName,
    required this.profileUrl,
    required this.title,
    required this.userType,
    required this.preferredLanguage,
    required this.locale,
    required this.timezone,
    required this.active,
    required this.names,
    required this.photos,
    required this.phoneNumbers,
    required this.addresses,
    required this.emails,
    required this.verifications,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
    required this.environmentId,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json['id'] as String,
        externalId: json['externalId'] as String,
        userName: json['userName'] as String,
        displayName: json['displayName'] as String,
        nickName: json['nickName'] as String?,
        profileUrl: json['profileUrl'] as String?,
        title: json['title'] as String?,
        userType: json['userType'] as String?,
        preferredLanguage: json['preferredLanguage'] as String?,
        locale: json['locale'] as String,
        timezone: json['timezone'] as String?,
        active: json['active'] as bool,
        names: Names.fromJson(json['names'] as Map<String, dynamic>),
        photos: ((json['photos'] as List<dynamic>)
                .map((e) => Photo.fromJson(e as Map<String, dynamic>)))
            .toList(),
        phoneNumbers: (json['phoneNumbers'] as List<dynamic>),
        addresses: (json['addresses'] as List<dynamic>),
        emails: ((json['emails'] as List<dynamic>)
                .map((e) => Email.fromJson(e as Map<String, dynamic>)))
            .toList(),
        verifications: ((json['verifications'] as List<dynamic>)
                .map((e) => Verification.fromJson(e as Map<String, dynamic>)))
            .toList(),
        provider: json['provider'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        environmentId: json['environmentId'] as String,
      );
}

class UserInfoResponse {
  final Meta meta;
  final SessionInfo session;
  final UserInfo user;
  UserInfoResponse({required this.meta, required this.session, required this.user});
  factory UserInfoResponse.fromJson(Map<String, dynamic> json) =>
      UserInfoResponse(
        meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
        session: SessionInfo.fromJson(json['session'] as Map<String, dynamic>),
        user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      );
}
