class Validations {
  static String? validateTitle(String? title) {
    if (title == null || title.isEmpty) {
      return "Please enter text";
    } else {
      return null;
    }
  }

  static String? validateSubTitle(String? title) {
    if (title == null || title.isEmpty) {
      return "Please enter text";
    } else {
      return null;
    }
  }
}
