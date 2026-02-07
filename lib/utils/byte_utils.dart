int findBytes(List<int> data, List<int> pattern, int start) {
  for (var i = start; i <= data.length - pattern.length; i++) {
    var found = true;
    for (var j = 0; j < pattern.length; j++) {
      if (data[i + j] != pattern[j]) {
        found = false;
        break;
      }
    }
    if (found) return i;
  }
  return -1;
}

bool compareBytes(List<int> data, int start, List<int> pattern) {
  if (start + pattern.length > data.length) return false;
  for (var i = 0; i < pattern.length; i++) {
    if (data[start + i] != pattern[i]) return false;
  }
  return true;
}
