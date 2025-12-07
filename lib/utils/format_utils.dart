String formatRam(double kb) {
  if (kb <= 0) {
    return 'N/A';
  }
  if (kb > 1024 * 1024) {
    return '${(kb / (1024 * 1024)).toStringAsFixed(2)} GB';
  } else if (kb > 1024) {
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
  return '${kb.toStringAsFixed(0)} KB';
}
