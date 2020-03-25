import 'dart:math';

String createRandomString(int size) {
  var buffer = StringBuffer();
  var min = 97;
  var max = 122;
  var rnd = Random();
  for (var i = 0; i < size; i++) {
    buffer.writeCharCode(min + rnd.nextInt(max - min));
  }
  return buffer.toString();
}
