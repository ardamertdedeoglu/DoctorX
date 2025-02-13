// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `DoctorX`
  String get appTitle {
    return Intl.message('DoctorX', name: 'appTitle', desc: '', args: []);
  }

  /// `Welcome`
  String get welcomeMessage {
    return Intl.message('Welcome', name: 'welcomeMessage', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Sign Up`
  String get signup {
    return Intl.message('Sign Up', name: 'signup', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Reports`
  String get reports {
    return Intl.message('Reports', name: 'reports', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Appointments`
  String get appointments {
    return Intl.message(
      'Appointments',
      name: 'appointments',
      desc: '',
      args: [],
    );
  }

  /// `My Wallet`
  String get wallet {
    return Intl.message('My Wallet', name: 'wallet', desc: '', args: []);
  }

  /// `News`
  String get news {
    return Intl.message('News', name: 'news', desc: '', args: []);
  }

  /// `Hospital`
  String get hospital {
    return Intl.message('Hospital', name: 'hospital', desc: '', args: []);
  }

  /// `Switch Account`
  String get accountSwitcher {
    return Intl.message(
      'Switch Account',
      name: 'accountSwitcher',
      desc: '',
      args: [],
    );
  }

  /// `Select Account Type`
  String get accountTypeDialog {
    return Intl.message(
      'Select Account Type',
      name: 'accountTypeDialog',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signupPageTitle {
    return Intl.message('Sign Up', name: 'signupPageTitle', desc: '', args: []);
  }

  /// `Login`
  String get loginPageTitle {
    return Intl.message('Login', name: 'loginPageTitle', desc: '', args: []);
  }

  /// `DoctorX`
  String get homePageTitle {
    return Intl.message('DoctorX', name: 'homePageTitle', desc: '', args: []);
  }

  /// `News Detail`
  String get newsDetailPageTitle {
    return Intl.message(
      'News Detail',
      name: 'newsDetailPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Profile Image`
  String get profileImage {
    return Intl.message(
      'Profile Image',
      name: 'profileImage',
      desc: '',
      args: [],
    );
  }

  /// `Family Service`
  String get familyService {
    return Intl.message(
      'Family Service',
      name: 'familyService',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, I can't help you with this. How else can I help you?`
  String get aiErrorMessage {
    return Intl.message(
      'Sorry, I can\'t help you with this. How else can I help you?',
      name: 'aiErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `You are being directed to the application...`
  String get enteringSentence {
    return Intl.message(
      'You are being directed to the application...',
      name: 'enteringSentence',
      desc: '',
      args: [],
    );
  }

  /// `Donation`
  String get donation {
    return Intl.message('Donation', name: 'donation', desc: '', args: []);
  }

  /// `You can donate to support patients in need.`
  String get donationDesc {
    return Intl.message(
      'You can donate to support patients in need.',
      name: 'donationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Dietician`
  String get dietician {
    return Intl.message('Dietician', name: 'dietician', desc: '', args: []);
  }

  /// `Create a healthy eating plan with our expert dieticians.`
  String get dieticianDesc {
    return Intl.message(
      'Create a healthy eating plan with our expert dieticians.',
      name: 'dieticianDesc',
      desc: '',
      args: [],
    );
  }

  /// `Therapy`
  String get therapy {
    return Intl.message('Therapy', name: 'therapy', desc: '', args: []);
  }

  /// `Maintain your mental health with our professional therapists.`
  String get therapyDesc {
    return Intl.message(
      'Maintain your mental health with our professional therapists.',
      name: 'therapyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Dietician+Therapy`
  String get dieticianTherapy {
    return Intl.message(
      'Dietician+Therapy',
      name: 'dieticianTherapy',
      desc: '',
      args: [],
    );
  }

  /// `Combined package for both your physical and mental health.`
  String get dieticianTherapyDesc {
    return Intl.message(
      'Combined package for both your physical and mental health.',
      name: 'dieticianTherapyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Health News`
  String get newsTitle {
    return Intl.message('Health News', name: 'newsTitle', desc: '', args: []);
  }

  /// `A new treatment method has been developed.`
  String get newsDesc1 {
    return Intl.message(
      'A new treatment method has been developed.',
      name: 'newsDesc1',
      desc: '',
      args: [],
    );
  }

  /// `Detailed content will be here...`
  String get newsContentPlaceholder {
    return Intl.message(
      'Detailed content will be here...',
      name: 'newsContentPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `New research results have been announced.`
  String get newsDesc2 {
    return Intl.message(
      'New research results have been announced.',
      name: 'newsDesc2',
      desc: '',
      args: [],
    );
  }

  /// `Flu outbreak warning.`
  String get newsDesc3 {
    return Intl.message(
      'Flu outbreak warning.',
      name: 'newsDesc3',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition recommendations.`
  String get newsDesc4 {
    return Intl.message(
      'Nutrition recommendations.',
      name: 'newsDesc4',
      desc: '',
      args: [],
    );
  }

  /// `Your email address has been successfully verified`
  String get emailVerificationSuccess {
    return Intl.message(
      'Your email address has been successfully verified',
      name: 'emailVerificationSuccess',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get defaultUsername {
    return Intl.message('User', name: 'defaultUsername', desc: '', args: []);
  }

  /// `We are preparing the app for you...`
  String get preparingApp {
    return Intl.message(
      'We are preparing the app for you...',
      name: 'preparingApp',
      desc: '',
      args: [],
    );
  }

  /// `Health News`
  String get newsContainer {
    return Intl.message(
      'Health News',
      name: 'newsContainer',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get welcomeMainMenu {
    return Intl.message('Hello', name: 'welcomeMainMenu', desc: '', args: []);
  }

  /// `Upcoming Appointments`
  String get upcomingAppointments {
    return Intl.message(
      'Upcoming Appointments',
      name: 'upcomingAppointments',
      desc: '',
      args: [],
    );
  }

  /// `Main Menu`
  String get mainMenuTitle {
    return Intl.message('Main Menu', name: 'mainMenuTitle', desc: '', args: []);
  }

  /// `Chats`
  String get chatsTitle {
    return Intl.message('Chats', name: 'chatsTitle', desc: '', args: []);
  }

  /// `Packages`
  String get packagesTitle {
    return Intl.message('Packages', name: 'packagesTitle', desc: '', args: []);
  }

  /// `In this page:\n• You can view your profile information and change them.\n• You can keep up with the current health news.\n• You can access content by searching.`
  String get mainMenuDesc {
    return Intl.message(
      'In this page:\n• You can view your profile information and change them.\n• You can keep up with the current health news.\n• You can access content by searching.',
      name: 'mainMenuDesc',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get searchLabel {
    return Intl.message('Search...', name: 'searchLabel', desc: '', args: []);
  }

  /// `Type the section you want to search`
  String get searchHelper {
    return Intl.message(
      'Type the section you want to search',
      name: 'searchHelper',
      desc: '',
      args: [],
    );
  }

  /// `Appointment`
  String get appointmentKeyword {
    return Intl.message(
      'Appointment',
      name: 'appointmentKeyword',
      desc: '',
      args: [],
    );
  }

  /// `JAN`
  String get january {
    return Intl.message('JAN', name: 'january', desc: '', args: []);
  }

  /// `FEB`
  String get february {
    return Intl.message('FEB', name: 'february', desc: '', args: []);
  }

  /// `MAR`
  String get march {
    return Intl.message('MAR', name: 'march', desc: '', args: []);
  }

  /// `APR`
  String get april {
    return Intl.message('APR', name: 'april', desc: '', args: []);
  }

  /// `MAY`
  String get may {
    return Intl.message('MAY', name: 'may', desc: '', args: []);
  }

  /// `JUN`
  String get june {
    return Intl.message('JUN', name: 'june', desc: '', args: []);
  }

  /// `JUL`
  String get july {
    return Intl.message('JUL', name: 'july', desc: '', args: []);
  }

  /// `AUG`
  String get august {
    return Intl.message('AUG', name: 'august', desc: '', args: []);
  }

  /// `SEP`
  String get september {
    return Intl.message('SEP', name: 'september', desc: '', args: []);
  }

  /// `OCT`
  String get october {
    return Intl.message('OCT', name: 'october', desc: '', args: []);
  }

  /// `NOV`
  String get november {
    return Intl.message('NOV', name: 'november', desc: '', args: []);
  }

  /// `DEC`
  String get december {
    return Intl.message('DEC', name: 'december', desc: '', args: []);
  }

  /// `Quick Access`
  String get quickAccessTitle {
    return Intl.message(
      'Quick Access',
      name: 'quickAccessTitle',
      desc: '',
      args: [],
    );
  }

  /// `Make an Appointment`
  String get quickAppointment {
    return Intl.message(
      'Make an Appointment',
      name: 'quickAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Diabetes`
  String get diabetes {
    return Intl.message('Diabetes', name: 'diabetes', desc: '', args: []);
  }

  /// `My Appointments`
  String get quickAppointmentsList {
    return Intl.message(
      'My Appointments',
      name: 'quickAppointmentsList',
      desc: '',
      args: [],
    );
  }

  /// `How may I be of service today?`
  String get aiFirstMessage {
    return Intl.message(
      'How may I be of service today?',
      name: 'aiFirstMessage',
      desc: '',
      args: [],
    );
  }

  /// `Type a message...`
  String get chatsHintText {
    return Intl.message(
      'Type a message...',
      name: 'chatsHintText',
      desc: '',
      args: [],
    );
  }

  /// `Your email address has not been verified yet. Please verify your email address.`
  String get notVerifiedEmailMessage {
    return Intl.message(
      'Your email address has not been verified yet. Please verify your email address.',
      name: 'notVerifiedEmailMessage',
      desc: '',
      args: [],
    );
  }

  /// `Donation Amount`
  String get donationAmount {
    return Intl.message(
      'Donation Amount',
      name: 'donationAmount',
      desc: '',
      args: [],
    );
  }

  /// `Amount (TL)`
  String get donationAmountLabel {
    return Intl.message(
      'Amount (TL)',
      name: 'donationAmountLabel',
      desc: '',
      args: [],
    );
  }

  /// `Fifty percent of your donation will be returned to your wallet.`
  String get donationReward {
    return Intl.message(
      'Fifty percent of your donation will be returned to your wallet.',
      name: 'donationReward',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your donation!`
  String get donationThanks {
    return Intl.message(
      'Thank you for your donation!',
      name: 'donationThanks',
      desc: '',
      args: [],
    );
  }

  /// `will be added after 7 days.`
  String get donationPendingTime {
    return Intl.message(
      'will be added after 7 days.',
      name: 'donationPendingTime',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Donate`
  String get donationConfirm {
    return Intl.message('Donate', name: 'donationConfirm', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
