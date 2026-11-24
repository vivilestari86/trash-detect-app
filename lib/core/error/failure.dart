/// Kesalahan yang pesannya aman ditampilkan langsung ke pengguna.
class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}
