class AppTexts {
  AppTexts._();

  // App
  static const String appName = 'Qoucher';
  static const String appTagline =
      'Lokale Deals. Punkte. Stempel. Ohne App-Stress.';

  // Auth
  static const String loginTitle = 'Willkommen bei Qoucher';
  static const String loginSubtitle =
      'Lokale Deals. Punkte. Stempel. Alles leicht, direkt und ohne App-Stress.';
  static const String registerTitle = 'Konto erstellen';
  static const String registerSubtitle =
      'Schnell rein ins grüne Spiel: sammeln, scannen, profitieren.';
  static const String forgotPasswordTitle = 'Passwort vergessen';
  static const String forgotPasswordSubtitle =
      'Kein Stress. Gib deine E-Mail ein und wir schicken dir später den Weg zurück ins Konto.';

  // Labels
  static const String labelName = 'Name';
  static const String labelEmail = 'E-Mail';
  static const String labelPassword = 'Passwort';

  // Placeholders
  static const String hintName = 'Dein Vorname oder Shopname';
  static const String hintEmail = 'deine@email.de';
  static const String hintPassword = 'Mindestens 6 Zeichen';

  // Buttons
  static const String loginButton = 'Einloggen';
  static const String registerButton = 'Registrieren';
  static const String forgotPasswordButton = 'Link senden';
  static const String backToLogin = 'Zurück zum Login';

  // Roles
  static const String customer = 'Kunde';
  static const String merchant = 'Merchant';

  // Links / Hints
  static const String noAccount = 'Noch kein Konto?';
  static const String hasAccount = 'Schon ein Konto?';
  static const String forgotPassword = 'Passwort vergessen?';

  // Helper texts
  static const String dummyAuthInfo =
      'Erstmal Dummy-Logik. Später hängen wir Firebase sauber dran.';
  static const String dummyLoginInfo =
      'Login erstmal als Dummy-Version. Firebase kommt später wie ein Boss dazu.';

  // Validation / Errors
  static const String fillAllFields = 'Bitte alle Felder ausfüllen.';
  static const String enterEmail = 'Bitte E-Mail eingeben.';
  static const String enterPassword = 'Bitte Passwort eingeben.';
  static const String enterName = 'Bitte Name eingeben.';
  static const String invalidEmail = 'Bitte eine gültige E-Mail eingeben.';
  static const String shortPassword = 'Passwort muss mindestens 6 Zeichen haben.';
  static const String shortName = 'Name ist zu kurz.';
  static const String minSixChars = 'Mindestens 6 Zeichen.';

  // Success
  static const String passwordResetSent = 'Passwort-Link wurde gesendet.';
  static const String loginSuccess = 'Login erfolgreich.';
  static const String registerSuccess = 'Konto erfolgreich erstellt.';

  // Public home
  static const String hottestDeals = 'Heißeste Deals';
  static const String participatingShops = 'Teilnehmende Läden';
  static const String currentOffers = 'Aktuelle Angebote';
  static const String discoverLocal = 'Entdecke, was lokal gerade läuft';

  // Empty states
  static const String noDealsFound = 'Keine Deals gefunden.';
  static const String noRewardsFound = 'Keine Rewards gefunden.';
  static const String noActivityFound = 'Noch keine Aktivität vorhanden.';
  static const String noMerchantsFound = 'Keine Läden gefunden.';
}