class TodoTaskTime {
  final Duration taskTime;

  TodoTaskTime({
    int days = 0,
    required int hours,
    required int minutes,
    int seconds = 0,
  }) : taskTime = Duration(
         days: days,
         hours: hours,
         minutes: minutes,
         seconds: seconds,
       );

  TodoTaskTime.createEmpty() : this(days: 0, hours: 0, minutes: 0, seconds: 0);

  TodoTaskTime copy() {
    return TodoTaskTime(
      days: taskTime.inDays,
      hours: taskTime.inHours % 24,
      minutes: taskTime.inMinutes % 60,
      seconds: taskTime.inSeconds % 60,
    );
  }

  @override
  String toString() {
    // Định dạng chuỗi để lưu vào DB (ví dụ: "01d:02h:30m:00s")
    // Đảm bảo định dạng này nhất quán khi lưu và đọc
    return '${taskTime.inDays.toString().padLeft(2, '0')}d:'
        '${(taskTime.inHours % 24).toString().padLeft(2, '0')}h:'
        '${(taskTime.inMinutes % 60).toString().padLeft(2, '0')}m:'
        '${(taskTime.inSeconds % 60).toString().padLeft(2, '0')}s';
  }

  // Factory constructor để tạo TodoTaskTime từ chuỗi lưu trong DB
  factory TodoTaskTime.fromString(String taskTimeString) {
    final regex = RegExp(r"(\d+)d:(\d+)h:(\d+)m:(\d+)s");
    final match = regex.firstMatch(taskTimeString);

    if (match == null) {
      // Xử lý trường hợp chuỗi không đúng định dạng
      throw FormatException("Invalid TodoTaskTime format: $taskTimeString");
    }

    return TodoTaskTime(
      days: int.parse(match.group(1)!),
      hours: int.parse(match.group(2)!),
      minutes: int.parse(match.group(3)!),
      seconds: int.parse(match.group(4)!),
    );
  }
}
