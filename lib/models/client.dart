class Client {
  final int id;
  final String name;
  final String lastName;
  final String mail;
  final String phone;
  final String password;

  Client({
    required this.id,
    required this.name,
    required this.lastName,
    required this.mail,
    required this.phone,
    required this.password,
  });

  Client.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lastName = json['last_name'],
        mail = json['mail'],
        phone = json['phone'],
        password = json['password'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'last_name': lastName,
    'mail': mail,
    'phone': phone,
    'password': password,
  };
}