String setTimeFormat({required int value, int? full}) {
  if (value == 0) return '00:00';

  int duration = full == null ? value : (full * full).floor();

  String minutes = (duration ~/ 60).toString().padLeft(2, '0');
  String secounds = (duration % 60).toString().padLeft(2, '0');
  return '$minutes:$secounds';
}
