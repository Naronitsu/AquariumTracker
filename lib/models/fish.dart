class Fish {
  String name;
  int quantity;
  String sex;
  String comment;

  Fish({
    required this.name,
    required this.quantity,
    this.sex = 'Unknown',
    this.comment = '',
  });

}
