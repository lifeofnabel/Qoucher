class Validators {
  Validators._();

  static String? requiredField(String? value, {String fieldName = 'Feld'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte $fieldName ausfüllen.';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Name eingeben.';
    }

    if (value.trim().length < 2) {
      return 'Name ist zu kurz.';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte E-Mail eingeben.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Bitte eine gültige E-Mail eingeben.';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Passwort eingeben.';
    }

    if (value.trim().length < 6) {
      return 'Passwort muss mindestens 6 Zeichen haben.';
    }

    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Username eingeben.';
    }

    if (value.trim().length < 3) {
      return 'Username ist zu kurz.';
    }

    return null;
  }

  static String? merchantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Shopnamen eingeben.';
    }

    if (value.trim().length < 2) {
      return 'Shopname ist zu kurz.';
    }

    return null;
  }

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Beschreibung eingeben.';
    }

    if (value.trim().length < 5) {
      return 'Beschreibung ist zu kurz.';
    }

    return null;
  }

  static String? points(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Punkte eingeben.';
    }

    final points = int.tryParse(value.trim());
    if (points == null || points <= 0) {
      return 'Bitte gültige Punkte eingeben.';
    }

    return null;
  }

  static String? stamps(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Stempelanzahl eingeben.';
    }

    final stamps = int.tryParse(value.trim());
    if (stamps == null || stamps <= 0) {
      return 'Bitte gültige Stempelanzahl eingeben.';
    }

    return null;
  }
}