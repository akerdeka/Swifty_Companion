import 'dart:convert';

class StudImageVersion {
  late String? large;
  late String? medium;
  late String? small;

  StudImageVersion({
    this.large = "",
    this.medium = "",
    this.small = "",
  });
}

class StudImage {
  late final StudImageVersion? versions;
  late final String? link;

  StudImage(dynamic studImage) {
    versions = studImage['versions'];
    link = studImage['link'];
  }
}

class Student {
  late final int id;
  late final String? email;
  late final String? login;
  late final String? first_name;
  late final String? last_name;
  late final String? usual_full_name;
  late final String? usual_first_name;
  late final String? url;
  late final String? phone;
  late final String? displayname;
  late final String? kind;
  late final StudImage? image;
  late final bool? staff;
  late final int? correction_point;
  late final String? pool_month;
  late final String? pool_year;
  late final String? location;
  late final int? wallet;
  late final String? anonymize_date;
  late final String? data_erasure_date;
  late final String? created_at;
  late final String? updated_at;
  late final String? alumnized_at;
  late final bool? alumni;
  late final bool? active;

  Student(dynamic stud) {
    id = stud['id'];
    email = stud['email'];
    login = stud['login'];
    first_name = stud['first_name'];
    last_name = stud['last_name'];
    usual_full_name = stud['usual_full_name'];
    usual_first_name = stud['usual_first_name'];
    url = stud['url'];
    phone = stud['phone'];
    displayname = stud['displayname'];
    kind = stud['kind'];
    Map<String, dynamic> img = stud['image'];
    StudImageVersion imgVersion = StudImageVersion(
      large: img['versions']['large'],
      medium: img['versions']['medium'],
      small: img['versions']['small'],
    );
    image = StudImage({
      'versions': imgVersion,
      'link': img['link'],
    });
    staff = stud['staff?'];
    correction_point = stud['correction_point'];
    pool_month = stud['pool_month'];
    pool_year = stud['pool_year'];
    location = stud['location'];
    wallet = stud['wallet'];
    anonymize_date = stud['anonymize_date'];
    data_erasure_date = stud['data_erasure_date'];
    created_at = stud['created_at'];
    updated_at = stud['updated_at'];

    if (stud['alumnized_at'] != null) {
      alumnized_at = stud['alumnized_at'];
    }
    alumni = stud['alumni?'];
    active = stud['active?'];
  }
}

