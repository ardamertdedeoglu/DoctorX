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

  /// 'Unknown hospital'
  String get unknownHospital {
    return Intl.message('Unknown hospital', name: 'unknownHospital', desc: '', args: []);
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

  /// `In this page:\n• You can chat with our AI powered assistant.\n• You can ask your questions about health related topics.\n• You can get information about the appointments and services.`
  String get chatsDesc {
    return Intl.message(
      'In this page:\n• You can chat with our AI powered assistant.\n• You can ask your questions about health related topics.\n• You can get information about the appointments and services.',
      name: 'chatsDesc',
      desc: '',
      args: [],
    );
  }

  /// `In this page:\n• You can examine our health-service packages.\n• You can make an appointment online.\n• You can donate.\n• You can buy our packages with a cheaper price than normal.`
  String get packagesDesc {
    return Intl.message(
      'In this page:\n• You can examine our health-service packages.\n• You can make an appointment online.\n• You can donate.\n• You can buy our packages with a cheaper price than normal.',
      name: 'packagesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Documents`
  String get documents {
    return Intl.message('Documents', name: 'documents', desc: '', args: []);
  }

  /// `About Us`
  String get aboutUsTitle {
    return Intl.message('About Us', name: 'aboutUsTitle', desc: '', args: []);
  }

  /// `Producers:`
  String get producersTitle {
    return Intl.message(
      'Producers:',
      name: 'producersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Release Date:`
  String get timeOfRelease {
    return Intl.message(
      'Release Date:',
      name: 'timeOfRelease',
      desc: '',
      args: [],
    );
  }

  /// `February 2025`
  String get timeOfReleaseValue {
    return Intl.message(
      'February 2025',
      name: 'timeOfReleaseValue',
      desc: '',
      args: [],
    );
  }

  /// `Goal:`
  String get goal {
    return Intl.message('Goal:', name: 'goal', desc: '', args: []);
  }

  /// `This application is designed to provide health services to patients whenever and wherever they want.`
  String get goalDesc {
    return Intl.message(
      'This application is designed to provide health services to patients whenever and wherever they want.',
      name: 'goalDesc',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Light Mode`
  String get lightMode {
    return Intl.message('Light Mode', name: 'lightMode', desc: '', args: []);
  }

  /// `You have no linked accounts.`
  String get noLinkedAccountsMessage {
    return Intl.message(
      'You have no linked accounts.',
      name: 'noLinkedAccountsMessage',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred.`
  String get basicErrorMessage {
    return Intl.message(
      'An error occurred.',
      name: 'basicErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Linked accounts could not be loaded.`
  String get loadErrorAccountSwitcher {
    return Intl.message(
      'Linked accounts could not be loaded.',
      name: 'loadErrorAccountSwitcher',
      desc: '',
      args: [],
    );
  }

  /// `Diabetes Tracking`
  String get searchItemDiabetesTitle {
    return Intl.message(
      'Diabetes Tracking',
      name: 'searchItemDiabetesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Health`
  String get searchCategoryHealth {
    return Intl.message(
      'Health',
      name: 'searchCategoryHealth',
      desc: '',
      args: [],
    );
  }

  /// `Track your diabetes values`
  String get searchItemDiabetesDesc {
    return Intl.message(
      'Track your diabetes values',
      name: 'searchItemDiabetesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Health Documents`
  String get searchItemDocumentsTitle {
    return Intl.message(
      'Health Documents',
      name: 'searchItemDocumentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Informative documents about health`
  String get searchItemDocumentsDesc {
    return Intl.message(
      'Informative documents about health',
      name: 'searchItemDocumentsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Health Reports`
  String get searchItemReportsTitle {
    return Intl.message(
      'Health Reports',
      name: 'searchItemReportsTitle',
      desc: '',
      args: [],
    );
  }

  /// `All your medical reports`
  String get searchItemReportsDesc {
    return Intl.message(
      'All your medical reports',
      name: 'searchItemReportsDesc',
      desc: '',
      args: [],
    );
  }

  /// `View all your past and upcoming appointments`
  String get searchItemAppointmentDesc {
    return Intl.message(
      'View all your past and upcoming appointments',
      name: 'searchItemAppointmentDesc',
      desc: '',
      args: [],
    );
  }

  /// `Health Assistant`
  String get searchItemChatsTitle {
    return Intl.message(
      'Health Assistant',
      name: 'searchItemChatsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Chat with our AI assistant about health topics`
  String get searchItemChatsDesc {
    return Intl.message(
      'Chat with our AI assistant about health topics',
      name: 'searchItemChatsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Frequently Asked Questions`
  String get searchItemQuestionsCategory {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'searchItemQuestionsCategory',
      desc: '',
      args: [],
    );
  }

  /// `e.g.:`
  String get searchItemQuestionDesc {
    return Intl.message(
      'e.g.:',
      name: 'searchItemQuestionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Price:`
  String get price {
    return Intl.message('Price:', name: 'price', desc: '', args: []);
  }

  /// `Hospital and Doctor Selection`
  String get hospitalDoctorTitle {
    return Intl.message(
      'Hospital and Doctor Selection',
      name: 'hospitalDoctorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Appointment Date and Time`
  String get appointmentDateAndTimeTitle {
    return Intl.message(
      'Appointment Date and Time',
      name: 'appointmentDateAndTimeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please verify your email address.`
  String get emailVerificationRequired {
    return Intl.message(
      'Please verify your email address.',
      name: 'emailVerificationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get buyKeyword {
    return Intl.message('Buy', name: 'buyKeyword', desc: '', args: []);
  }

  /// `Select a Date`
  String get dateSelection {
    return Intl.message(
      'Select a Date',
      name: 'dateSelection',
      desc: '',
      args: [],
    );
  }

  /// `Available Hours:`
  String get availableHours {
    return Intl.message(
      'Available Hours:',
      name: 'availableHours',
      desc: '',
      args: [],
    );
  }

  /// `Payment Options`
  String get paymentTitle {
    return Intl.message(
      'Payment Options',
      name: 'paymentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Details of Appointment`
  String get appointmentPaymentTitle {
    return Intl.message(
      'Details of Appointment',
      name: 'appointmentPaymentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Date:`
  String get appointmentPaymentDate {
    return Intl.message(
      'Date:',
      name: 'appointmentPaymentDate',
      desc: '',
      args: [],
    );
  }

  /// `Hour:`
  String get appointmentPaymentTime {
    return Intl.message(
      'Hour:',
      name: 'appointmentPaymentTime',
      desc: '',
      args: [],
    );
  }

  /// `Package:`
  String get appointmentPaymentPackage {
    return Intl.message(
      'Package:',
      name: 'appointmentPaymentPackage',
      desc: '',
      args: [],
    );
  }

  /// `Package Amount:`
  String get appointmentPaymentAmount {
    return Intl.message(
      'Package Amount:',
      name: 'appointmentPaymentAmount',
      desc: '',
      args: [],
    );
  }

  /// `Your Wallet Balance:`
  String get appointmentPaymentWallet {
    return Intl.message(
      'Your Wallet Balance:',
      name: 'appointmentPaymentWallet',
      desc: '',
      args: [],
    );
  }

  /// `Pay with Wallet Balance`
  String get paymentWithWallet {
    return Intl.message(
      'Pay with Wallet Balance',
      name: 'paymentWithWallet',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient balance. Remaining Amount:`
  String get notEnoughWallet {
    return Intl.message(
      'Insufficient balance. Remaining Amount:',
      name: 'notEnoughWallet',
      desc: '',
      args: [],
    );
  }

  /// `Pay with Wallet + Card`
  String get walletPlusCardPayment {
    return Intl.message(
      'Pay with Wallet + Card',
      name: 'walletPlusCardPayment',
      desc: '',
      args: [],
    );
  }

  /// `Pay With Credit/Debit Card`
  String get payWithCard {
    return Intl.message(
      'Pay With Credit/Debit Card',
      name: 'payWithCard',
      desc: '',
      args: [],
    );
  }

  /// `Pay with Card`
  String get payWithCardTitle {
    return Intl.message(
      'Pay with Card',
      name: 'payWithCardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Amount to be paid:`
  String get cardPaymentAmount {
    return Intl.message(
      'Amount to be paid:',
      name: 'cardPaymentAmount',
      desc: '',
      args: [],
    );
  }

  /// `Card Number`
  String get cardNumber {
    return Intl.message('Card Number', name: 'cardNumber', desc: '', args: []);
  }

  /// `MM/YY`
  String get cardEndDate {
    return Intl.message('MM/YY', name: 'cardEndDate', desc: '', args: []);
  }

  /// `Please enter a valid card number`
  String get invalidCardMessage {
    return Intl.message(
      'Please enter a valid card number',
      name: 'invalidCardMessage',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Payment`
  String get confirmPayment {
    return Intl.message(
      'Confirm Payment',
      name: 'confirmPayment',
      desc: '',
      args: [],
    );
  }

  /// `Your appointment has been successfully created.`
  String get appointmentSuccess {
    return Intl.message(
      'Your appointment has been successfully created.',
      name: 'appointmentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while creating your appointment.`
  String get appointmentFailure {
    return Intl.message(
      'An error occurred while creating your appointment.',
      name: 'appointmentFailure',
      desc: '',
      args: [],
    );
  }

  /// `Child Information`
  String get childInformation {
    return Intl.message(
      'Child Information',
      name: 'childInformation',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `This field is required`
  String get requiredField {
    return Intl.message(
      'This field is required',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `E-Mail`
  String get emailLabel {
    return Intl.message('E-Mail', name: 'emailLabel', desc: '', args: []);
  }

  /// `Please enter a valid email address`
  String get invalidEmailMessage {
    return Intl.message(
      'Please enter a valid email address',
      name: 'invalidEmailMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get addKeyword {
    return Intl.message('Add', name: 'addKeyword', desc: '', args: []);
  }

  /// `Child account successfully linked.`
  String get childAccountConnectionSuccess {
    return Intl.message(
      'Child account successfully linked.',
      name: 'childAccountConnectionSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while linking the child account.`
  String get childAccountConnectionFailure {
    return Intl.message(
      'An error occurred while linking the child account.',
      name: 'childAccountConnectionFailure',
      desc: '',
      args: [],
    );
  }

  /// `A child account with this email address does not exist.`
  String get childAccountNonExistent {
    return Intl.message(
      'A child account with this email address does not exist.',
      name: 'childAccountNonExistent',
      desc: '',
      args: [],
    );
  }

  /// `No results found.`
  String get searchEmpty {
    return Intl.message(
      'No results found.',
      name: 'searchEmpty',
      desc: '',
      args: [],
    );
  }

  /// `You have no upcoming appointments.`
  String get noUpcomingAppointments {
    return Intl.message(
      'You have no upcoming appointments.',
      name: 'noUpcomingAppointments',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yesButton {
    return Intl.message('Yes', name: 'yesButton', desc: '', args: []);
  }

  /// `No`
  String get noButton {
    return Intl.message('No', name: 'noButton', desc: '', args: []);
  }

  /// `Would you like to add your children's accounts?`
  String get childAccountConnectionQuestion {
    return Intl.message(
      'Would you like to add your children\'s accounts?',
      name: 'childAccountConnectionQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Verify E-mail`
  String get emailVerificitaionButton {
    return Intl.message(
      'Verify E-mail',
      name: 'emailVerificitaionButton',
      desc: '',
      args: [],
    );
  }

  /// `Child Account`
  String get childAccountTitle {
    return Intl.message(
      'Child Account',
      name: 'childAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while loading user data.`
  String get userDataLoadError {
    return Intl.message(
      'An error occurred while loading user data.',
      name: 'userDataLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Choose from Gallery`
  String get chooseFromGalleryButton {
    return Intl.message(
      'Choose from Gallery',
      name: 'chooseFromGalleryButton',
      desc: '',
      args: [],
    );
  }

  /// `Take a Photo`
  String get cameraButton {
    return Intl.message(
      'Take a Photo',
      name: 'cameraButton',
      desc: '',
      args: [],
    );
  }

  /// `Remove Photo`
  String get removePhotoButton {
    return Intl.message(
      'Remove Photo',
      name: 'removePhotoButton',
      desc: '',
      args: [],
    );
  }

  /// `Hello! How can I help you?`
  String get AIGreetingResponse {
    return Intl.message(
      'Hello! How can I help you?',
      name: 'AIGreetingResponse',
      desc: '',
      args: [],
    );
  }

  /// `I'm fine, thank you. How can I help you?`
  String get AIChattingResponse {
    return Intl.message(
      'I\'m fine, thank you. How can I help you?',
      name: 'AIChattingResponse',
      desc: '',
      args: [],
    );
  }

  /// `Please select a service from the packages tab to make an appointment.`
  String get AIAppointmentResponse {
    return Intl.message(
      'Please select a service from the packages tab to make an appointment.',
      name: 'AIAppointmentResponse',
      desc: '',
      args: [],
    );
  }

  /// `Please specify your complaint to find a suitable doctor for you.`
  String get AIDoctorResponse {
    return Intl.message(
      'Please specify your complaint to find a suitable doctor for you.',
      name: 'AIDoctorResponse',
      desc: '',
      args: [],
    );
  }

  /// `You can see our prices in the packages tab.`
  String get AIPriceResponse {
    return Intl.message(
      'You can see our prices in the packages tab.',
      name: 'AIPriceResponse',
      desc: '',
      args: [],
    );
  }

  /// `You're welcome! Can I help you with anything else?`
  String get AIThanksResponse {
    return Intl.message(
      'You\'re welcome! Can I help you with anything else?',
      name: 'AIThanksResponse',
      desc: '',
      args: [],
    );
  }

  /// `Verification email has been sent. Please check your email.`
  String get emailVerificationSent {
    return Intl.message(
      'Verification email has been sent. Please check your email.',
      name: 'emailVerificationSent',
      desc: '',
      args: [],
    );
  }

  /// `E-mail is already verified.`
  String get emailAlreadyVerified {
    return Intl.message(
      'E-mail is already verified.',
      name: 'emailAlreadyVerified',
      desc: '',
      args: [],
    );
  }

  /// `User session not found. Please log in again.`
  String get AccountFindError {
    return Intl.message(
      'User session not found. Please log in again.',
      name: 'AccountFindError',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while sending the verification email:`
  String get emailVerificationTechnicalError {
    return Intl.message(
      'An error occurred while sending the verification email:',
      name: 'emailVerificationTechnicalError',
      desc: '',
      args: [],
    );
  }

  /// `Profile Information`
  String get profileDialogTitle {
    return Intl.message(
      'Profile Information',
      name: 'profileDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Account Type:`
  String get accountType {
    return Intl.message(
      'Account Type:',
      name: 'accountType',
      desc: '',
      args: [],
    );
  }

  /// `Parent`
  String get parentAccount {
    return Intl.message('Parent', name: 'parentAccount', desc: '', args: []);
  }

  /// `Normal Account`
  String get normalAccount {
    return Intl.message(
      'Normal Account',
      name: 'normalAccount',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade to Parent Account`
  String get upgradeToParent {
    return Intl.message(
      'Upgrade to Parent Account',
      name: 'upgradeToParent',
      desc: '',
      args: [],
    );
  }

  /// `New E-mail`
  String get newEmailLabel {
    return Intl.message(
      'New E-mail',
      name: 'newEmailLabel',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while updating the password:`
  String get passwordUpdateError {
    return Intl.message(
      'An error occurred while updating the password:',
      name: 'passwordUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `Information updated`
  String get passwordUpdateSuccess {
    return Intl.message(
      'Information updated',
      name: 'passwordUpdateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Choose Hospital`
  String get chooseHospitalLabel {
    return Intl.message(
      'Choose Hospital',
      name: 'chooseHospitalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Choose Doctor`
  String get chooseDoctor {
    return Intl.message(
      'Choose Doctor',
      name: 'chooseDoctor',
      desc: '',
      args: [],
    );
  }

  /// `Choose Account Type`
  String get chooseAccountType {
    return Intl.message(
      'Choose Account Type',
      name: 'chooseAccountType',
      desc: '',
      args: [],
    );
  }

  /// `Mother`
  String get mother {
    return Intl.message('Mother', name: 'mother', desc: '', args: []);
  }

  /// `Father`
  String get father {
    return Intl.message('Father', name: 'father', desc: '', args: []);
  }

  /// `Past`
  String get pastAppointments {
    return Intl.message('Past', name: 'pastAppointments', desc: '', args: []);
  }

  /// `Present`
  String get futureAppointments {
    return Intl.message(
      'Present',
      name: 'futureAppointments',
      desc: '',
      args: [],
    );
  }

  /// `You have no past appointments.`
  String get noPastAppointments {
    return Intl.message(
      'You have no past appointments.',
      name: 'noPastAppointments',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get editButton {
    return Intl.message('Edit', name: 'editButton', desc: '', args: []);
  }

  /// `h`
  String get hour {
    return Intl.message('h', name: 'hour', desc: '', args: []);
  }

  /// `m`
  String get minutes {
    return Intl.message('m', name: 'minutes', desc: '', args: []);
  }

  /// `Congratulations, one step closer to being healthy!`
  String get doseConfirmedMessage {
    return Intl.message(
      'Congratulations, one step closer to being healthy!',
      name: 'doseConfirmedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Oh no, don't forget again!`
  String get doseNotConfirmedMessage {
    return Intl.message(
      'Oh no, don\'t forget again!',
      name: 'doseNotConfirmedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Dose Confirmation`
  String get doseConfirm {
    return Intl.message(
      'Dose Confirmation',
      name: 'doseConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you took this dose?`
  String get doseConfirmationDesc {
    return Intl.message(
      'Are you sure you took this dose?',
      name: 'doseConfirmationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Insulin Dose`
  String get doseTitle {
    return Intl.message('Insulin Dose', name: 'doseTitle', desc: '', args: []);
  }

  /// `Morning Dose (11:00)`
  String get morningDose {
    return Intl.message(
      'Morning Dose (11:00)',
      name: 'morningDose',
      desc: '',
      args: [],
    );
  }

  /// `Evening Dose (20:00)`
  String get eveningDose {
    return Intl.message(
      'Evening Dose (20:00)',
      name: 'eveningDose',
      desc: '',
      args: [],
    );
  }

  /// `Remaining time:`
  String get remainingTime {
    return Intl.message(
      'Remaining time:',
      name: 'remainingTime',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get morning {
    return Intl.message('Morning', name: 'morning', desc: '', args: []);
  }

  /// `Evening`
  String get evening {
    return Intl.message('Evening', name: 'evening', desc: '', args: []);
  }

  /// `Glucose Level`
  String get glucoseLevel {
    return Intl.message(
      'Glucose Level',
      name: 'glucoseLevel',
      desc: '',
      args: [],
    );
  }

  /// `Glucose level should be reduced!`
  String get tooMuchGlucose {
    return Intl.message(
      'Glucose level should be reduced!',
      name: 'tooMuchGlucose',
      desc: '',
      args: [],
    );
  }

  /// `Increase your glucose consumption!`
  String get tooLowGlucose {
    return Intl.message(
      'Increase your glucose consumption!',
      name: 'tooLowGlucose',
      desc: '',
      args: [],
    );
  }

  /// `Keep it up!`
  String get normalGlucose {
    return Intl.message(
      'Keep it up!',
      name: 'normalGlucose',
      desc: '',
      args: [],
    );
  }

  /// `Carbohydrates`
  String get carbonhydrates {
    return Intl.message(
      'Carbohydrates',
      name: 'carbonhydrates',
      desc: '',
      args: [],
    );
  }

  /// `Available Balance`
  String get availableBalance {
    return Intl.message(
      'Available Balance',
      name: 'availableBalance',
      desc: '',
      args: [],
    );
  }

  /// `Pending Balance:`
  String get pendingBalance {
    return Intl.message(
      'Pending Balance:',
      name: 'pendingBalance',
      desc: '',
      args: [],
    );
  }

  /// `Top Up Balance`
  String get addBalance {
    return Intl.message(
      'Top Up Balance',
      name: 'addBalance',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPasswordTitle {
    return Intl.message(
      'Reset Password',
      name: 'resetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Email is required.`
  String get requiredEmail {
    return Intl.message(
      'Email is required.',
      name: 'requiredEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password is required.`
  String get requiredPassword {
    return Intl.message(
      'Password is required.',
      name: 'requiredPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters.`
  String get passwordMinLength {
    return Intl.message(
      'Password must be at least 6 characters.',
      name: 'passwordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `No user found with this email address.`
  String get userNotFound {
    return Intl.message(
      'No user found with this email address.',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get wrongPassword {
    return Intl.message(
      'Incorrect password',
      name: 'wrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter the email address to which the password reset link will be sent:`
  String get emailForResettingPassword {
    return Intl.message(
      'Enter the email address to which the password reset link will be sent:',
      name: 'emailForResettingPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Remember Me`
  String get rememberMe {
    return Intl.message('Remember Me', name: 'rememberMe', desc: '', args: []);
  }

  /// `Forgot your password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot your password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? Sign up`
  String get signupButton {
    return Intl.message(
      'Don\'t have an account? Sign up',
      name: 'signupButton',
      desc: '',
      args: [],
    );
  }

  /// `Password reset link has been sent to your email address.`
  String get resetLinkConfirmed {
    return Intl.message(
      'Password reset link has been sent to your email address.',
      name: 'resetLinkConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Password reset error:`
  String get resetLinkError {
    return Intl.message(
      'Password reset error:',
      name: 'resetLinkError',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all fields`
  String get requiredAll {
    return Intl.message(
      'Please fill in all fields',
      name: 'requiredAll',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak`
  String get weakPassword {
    return Intl.message(
      'Password is too weak',
      name: 'weakPassword',
      desc: '',
      args: [],
    );
  }

  /// `This email address is already in use`
  String get emailAlreadyInUse {
    return Intl.message(
      'This email address is already in use',
      name: 'emailAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while signing up:`
  String get signError {
    return Intl.message(
      'An error occurred while signing up:',
      name: 'signError',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred:`
  String get unexpectedError {
    return Intl.message(
      'An unexpected error occurred:',
      name: 'unexpectedError',
      desc: '',
      args: [],
    );
  }

  /// `Verify Password`
  String get verifyPassword {
    return Intl.message(
      'Verify Password',
      name: 'verifyPassword',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get allReports {
    return Intl.message('All', name: 'allReports', desc: '', args: []);
  }

  /// `Blood Test Results`
  String get reportsTitle1 {
    return Intl.message(
      'Blood Test Results',
      name: 'reportsTitle1',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while loading the PDF:`
  String get pdfError {
    return Intl.message(
      'An error occurred while loading the PDF:',
      name: 'pdfError',
      desc: '',
      args: [],
    );
  }

  /// `Delete Report`
  String get deleteReportTitle {
    return Intl.message(
      'Delete Report',
      name: 'deleteReportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this report?`
  String get deleteReportDesc {
    return Intl.message(
      'Are you sure you want to delete this report?',
      name: 'deleteReportDesc',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message('Delete', name: 'deleteButton', desc: '', args: []);
  }

  /// `Report deleted successfully.`
  String get deleteReportSuccess {
    return Intl.message(
      'Report deleted successfully.',
      name: 'deleteReportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `My Reports`
  String get reportsPageTitle {
    return Intl.message(
      'My Reports',
      name: 'reportsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search for a report or a doctor...`
  String get searchReports {
    return Intl.message(
      'Search for a report or a doctor...',
      name: 'searchReports',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get openPdfViewer {
    return Intl.message('View', name: 'openPdfViewer', desc: '', args: []);
  }

  /// `Search for a document...`
  String get searchDocuments {
    return Intl.message(
      'Search for a document...',
      name: 'searchDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Internal Medicine`
  String get reportsDepartment1 {
    return Intl.message(
      'Internal Medicine',
      name: 'reportsDepartment1',
      desc: '',
      args: [],
    );
  }

  /// `MRI Results`
  String get reportsTitle2 {
    return Intl.message(
      'MRI Results',
      name: 'reportsTitle2',
      desc: '',
      args: [],
    );
  }

  /// `Cardiology`
  String get reportsDepartment2 {
    return Intl.message(
      'Cardiology',
      name: 'reportsDepartment2',
      desc: '',
      args: [],
    );
  }

  /// `X-Ray of Lungs Results`
  String get reportsTitle3 {
    return Intl.message(
      'X-Ray of Lungs Results',
      name: 'reportsTitle3',
      desc: '',
      args: [],
    );
  }

  /// `Pulmonology`
  String get reportsDepartment3 {
    return Intl.message(
      'Pulmonology',
      name: 'reportsDepartment3',
      desc: '',
      args: [],
    );
  }

  /// `MR Scan Results`
  String get reportsTitle4 {
    return Intl.message(
      'MR Scan Results',
      name: 'reportsTitle4',
      desc: '',
      args: [],
    );
  }

  /// `Neurology`
  String get reportsDepartment4 {
    return Intl.message(
      'Neurology',
      name: 'reportsDepartment4',
      desc: '',
      args: [],
    );
  }

  /// `What is Diabetes?`
  String get documentTitle1 {
    return Intl.message(
      'What is Diabetes?',
      name: 'documentTitle1',
      desc: '',
      args: [],
    );
  }

  /// `Basic information about diabetes`
  String get documentSummary1 {
    return Intl.message(
      'Basic information about diabetes',
      name: 'documentSummary1',
      desc: '',
      args: [],
    );
  }

  /// `Diabetes is a chronic disease that occurs when the pancreas does not produce enough insulin or when the body cannot effectively use the insulin it produces. Insulin is a hormone that regulates blood sugar. Hyperglycemia, or high blood sugar, is a common effect of uncontrolled diabetes and over time leads to serious damage to many of the body's systems, especially the nerves and blood vessels.`
  String get documentContent1 {
    return Intl.message(
      'Diabetes is a chronic disease that occurs when the pancreas does not produce enough insulin or when the body cannot effectively use the insulin it produces. Insulin is a hormone that regulates blood sugar. Hyperglycemia, or high blood sugar, is a common effect of uncontrolled diabetes and over time leads to serious damage to many of the body\'s systems, especially the nerves and blood vessels.',
      name: 'documentContent1',
      desc: '',
      args: [],
    );
  }

  /// `Type 2 Diabetes Treatment`
  String get documentTitle2 {
    return Intl.message(
      'Type 2 Diabetes Treatment',
      name: 'documentTitle2',
      desc: '',
      args: [],
    );
  }

  /// `Treatment methods for type 2 diabetes`
  String get documentSummary2 {
    return Intl.message(
      'Treatment methods for type 2 diabetes',
      name: 'documentSummary2',
      desc: '',
      args: [],
    );
  }

  /// `The main goal of type 2 diabetes treatment is to maintain blood sugar levels within the normal range. Treatment methods include lifestyle changes, oral medications, and insulin therapy. The treatment plan is determined by the doctor according to the patient's blood sugar level, age, and other health problems.`
  String get documentContent2 {
    return Intl.message(
      'The main goal of type 2 diabetes treatment is to maintain blood sugar levels within the normal range. Treatment methods include lifestyle changes, oral medications, and insulin therapy. The treatment plan is determined by the doctor according to the patient\'s blood sugar level, age, and other health problems.',
      name: 'documentContent2',
      desc: '',
      args: [],
    );
  }

  /// `Healthy Eating Guide`
  String get documentTitle3 {
    return Intl.message(
      'Healthy Eating Guide',
      name: 'documentTitle3',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition`
  String get documentCategory {
    return Intl.message(
      'Nutrition',
      name: 'documentCategory',
      desc: '',
      args: [],
    );
  }

  /// `Balanced and healthy nutrition recommendations`
  String get documentSummary3 {
    return Intl.message(
      'Balanced and healthy nutrition recommendations',
      name: 'documentSummary3',
      desc: '',
      args: [],
    );
  }

  /// `Healthy nutrition requires taking in all the nutrients our body needs in a balanced way...`
  String get documentContent3 {
    return Intl.message(
      'Healthy nutrition requires taking in all the nutrients our body needs in a balanced way...',
      name: 'documentContent3',
      desc: '',
      args: [],
    );
  }

  /// `You cannot edit an appointment within 3 days of the appointment date.`
  String get cantEditAppointmentWithin3Days {
    return Intl.message(
      'You cannot edit an appointment within 3 days of the appointment date.',
      name: 'cantEditAppointmentWithin3Days',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Appointment`
  String get confirmCancellation {
    return Intl.message(
      'Cancel Appointment',
      name: 'confirmCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this appointment?`
  String get cancelAppointmentConfirmation {
    return Intl.message(
      'Are you sure you want to cancel this appointment?',
      name: 'cancelAppointmentConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Carbohydrates Tracking`
  String get carbohydratesTracking {
    return Intl.message(
      'Carbohydrates Tracking',
      name: 'carbohydratesTracking',
      desc: '',
      args: [],
    );
  }

  /// `Today's Consumption:`
  String get consumptionToday {
    return Intl.message(
      'Today\'s Consumption:',
      name: 'consumptionToday',
      desc: '',
      args: [],
    );
  }

  /// `Calories:`
  String get calories {
    return Intl.message('Calories:', name: 'calories', desc: '', args: []);
  }

  /// `What did you eat today?`
  String get eatQuestion {
    return Intl.message(
      'What did you eat today?',
      name: 'eatQuestion',
      desc: '',
      args: [],
    );
  }

  /// `carbohydrates`
  String get carbohydrates {
    return Intl.message(
      'carbohydrates',
      name: 'carbohydrates',
      desc: '',
      args: [],
    );
  }

  /// `Insulin Tracking`
  String get insulineTracking {
    return Intl.message(
      'Insulin Tracking',
      name: 'insulineTracking',
      desc: '',
      args: [],
    );
  }

  /// `Apple`
  String get apple {
    return Intl.message('Apple', name: 'apple', desc: '', args: []);
  }

  /// `Banana`
  String get banana {
    return Intl.message('Banana', name: 'banana', desc: '', args: []);
  }

  /// `1 unit`
  String get oneUnit {
    return Intl.message('1 unit', name: 'oneUnit', desc: '', args: []);
  }

  /// `1 slice`
  String get oneSlice {
    return Intl.message('1 slice', name: 'oneSlice', desc: '', args: []);
  }

  /// `1 portion`
  String get onePortion {
    return Intl.message('1 portion', name: 'onePortion', desc: '', args: []);
  }

  /// `1 glass`
  String get oneGlass {
    return Intl.message('1 glass', name: 'oneGlass', desc: '', args: []);
  }

  /// `1 bowl`
  String get oneBowl {
    return Intl.message('1 bowl', name: 'oneBowl', desc: '', args: []);
  }

  /// `medium size`
  String get mediumSize {
    return Intl.message('medium size', name: 'mediumSize', desc: '', args: []);
  }

  /// `Bread`
  String get bread {
    return Intl.message('Bread', name: 'bread', desc: '', args: []);
  }

  /// `Rice`
  String get rice {
    return Intl.message('Rice', name: 'rice', desc: '', args: []);
  }

  /// `Pasta`
  String get pasta {
    return Intl.message('Pasta', name: 'pasta', desc: '', args: []);
  }

  /// `Milk`
  String get milk {
    return Intl.message('Milk', name: 'milk', desc: '', args: []);
  }

  /// `Yogurt`
  String get yogurt {
    return Intl.message('Yogurt', name: 'yogurt', desc: '', args: []);
  }

  /// `Potato`
  String get potato {
    return Intl.message('Potato', name: 'potato', desc: '', args: []);
  }

  /// `Send`
  String get sendButton {
    return Intl.message('Send', name: 'sendButton', desc: '', args: []);
  }

  /// `I am a Doctor`
  String get iAmDoctor {
    return Intl.message('I am a Doctor', name: 'iAmDoctor', desc: '', args: []);
  }

  /// `Title (Prof. Dr., Assoc. Dr., etc.)`
  String get doctorTitle {
    return Intl.message(
      'Title (Prof. Dr., Assoc. Dr., etc.)',
      name: 'doctorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Medical Specialization`
  String get specialization {
    return Intl.message(
      'Medical Specialization',
      name: 'specialization',
      desc: '',
      args: [],
    );
  }

  /// `Medical License Number`
  String get licenseNumber {
    return Intl.message(
      'Medical License Number',
      name: 'licenseNumber',
      desc: '',
      args: [],
    );
  }

  /// `Your documents will be verified`
  String get verifyDocuments {
    return Intl.message(
      'Your documents will be verified',
      name: 'verifyDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Patients`
  String get patients {
    return Intl.message('Patients', name: 'patients', desc: '', args: []);
  }

  /// `Send Message`
  String get sendMessage {
    return Intl.message(
      'Send Message',
      name: 'sendMessage',
      desc: '',
      args: [],
    );
  }

  /// `Voice Call`
  String get voiceCall {
    return Intl.message('Voice Call', name: 'voiceCall', desc: '', args: []);
  }

  /// `Video Call`
  String get videoCall {
    return Intl.message('Video Call', name: 'videoCall', desc: '', args: []);
  }

  /// `Last Visit:`
  String get lastVisit {
    return Intl.message('Last Visit:', name: 'lastVisit', desc: '', args: []);
  }

  /// `Add Child Account`
  String get addChildAccount {
    return Intl.message(
      'Add Child Account',
      name: 'addChildAccount',
      desc: '',
      args: [],
    );
  }

  /// `Search for a patient...`
  String get searchPatients {
    return Intl.message(
      'Search for a patient...',
      name: 'searchPatients',
      desc: '',
      args: [],
    );
  }

  /// `Last Seen:`
  String get lastSeen {
    return Intl.message('Last Seen:', name: 'lastSeen', desc: '', args: []);
  }

  /// `This feature is not available yet.`
  String get featureNotAvailable {
    return Intl.message(
      'This feature is not available yet.',
      name: 'featureNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Cardiology, Neurology`
  String get specializationHintText {
    return Intl.message(
      'e.g. Cardiology, Neurology',
      name: 'specializationHintText',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 123456`
  String get licenseNumberHintText {
    return Intl.message(
      'e.g. 123456',
      name: 'licenseNumberHintText',
      desc: '',
      args: [],
    );
  }

  /// `View Patients`
  String get viewPatients {
    return Intl.message(
      'View Patients',
      name: 'viewPatients',
      desc: '',
      args: [],
    );
  }

  /// `Doctor Account`
  String get doctorAccount {
    return Intl.message(
      'Doctor Account',
      name: 'doctorAccount',
      desc: '',
      args: [],
    );
  }

  /// `Update Doctor Information`
  String get updateDoctorInfo {
    return Intl.message(
      'Update Doctor Information',
      name: 'updateDoctorInfo',
      desc: '',
      args: [],
    );
  }

  /// `Add Doctor Account`
  String get addDoctorAccount {
    return Intl.message(
      'Add Doctor Account',
      name: 'addDoctorAccount',
      desc: '',
      args: [],
    );
  }

  /// `You will need to provide your medical license and other professional details to create a doctor account.`
  String get doctorAccountInfo {
    return Intl.message(
      'You will need to provide your medical license and other professional details to create a doctor account.',
      name: 'doctorAccountInfo',
      desc: '',
      args: [],
    );
  }

  /// `Continue to Registration`
  String get continueToRegistration {
    return Intl.message(
      'Continue to Registration',
      name: 'continueToRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Select Account`
  String get selectAccount {
    return Intl.message(
      'Select Account',
      name: 'selectAccount',
      desc: '',
      args: [],
    );
  }

  /// `Doctor account created successfully.`
  String get doctorAccountCreated {
    return Intl.message(
      'Doctor account created successfully.',
      name: 'doctorAccountCreated',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalidEmail {
    return Intl.message(
      'Invalid email address',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Create Doctor Account`
  String get createDoctorAccount {
    return Intl.message(
      'Create Doctor Account',
      name: 'createDoctorAccount',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while creating the doctor account.`
  String get doctorAccountCreationError {
    return Intl.message(
      'An error occurred while creating the doctor account.',
      name: 'doctorAccountCreationError',
      desc: '',
      args: [],
    );
  }

  /// `No doctors available.`
  String get noDoctorsAvailable {
    return Intl.message(
      'No doctors available.',
      name: 'noDoctorsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `You cannot remove your current account.`
  String get cannotRemoveCurrentAccount {
    return Intl.message(
      'You cannot remove your current account.',
      name: 'cannotRemoveCurrentAccount',
      desc: '',
      args: [],
    );
  }

  /// `Remove Account`
  String get removeAccount {
    return Intl.message(
      'Remove Account',
      name: 'removeAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this account?`
  String get removeAccountConfirmation {
    return Intl.message(
      'Are you sure you want to remove this account?',
      name: 'removeAccountConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Account removed successfully.`
  String get accountRemoved {
    return Intl.message(
      'Account removed successfully.',
      name: 'accountRemoved',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while removing the account.`
  String get accountRemoveError {
    return Intl.message(
      'An error occurred while removing the account.',
      name: 'accountRemoveError',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while switching accounts.`
  String get errorSwitchingAccount {
    return Intl.message(
      'An error occurred while switching accounts.',
      name: 'errorSwitchingAccount',
      desc: '',
      args: [],
    );
  }

  /// `No packages available.`
  String get noPackagesAvailable {
    return Intl.message(
      'No packages available.',
      name: 'noPackagesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message('Try Again', name: 'tryAgain', desc: '', args: []);
  }

  /// `Parent`
  String get parent {
    return Intl.message('Parent', name: 'parent', desc: '', args: []);
  }

  /// `Neurology`
  String get department4name {
    return Intl.message(
      'Neurology',
      name: 'department4name',
      desc: '',
      args: [],
    );
  }

  /// `Orthopedics`
  String get department2name {
    return Intl.message(
      'Orthopedics',
      name: 'department2name',
      desc: '',
      args: [],
    );
  }

  /// `Internal Medicine`
  String get department3name {
    return Intl.message(
      'Internal Medicine',
      name: 'department3name',
      desc: '',
      args: [],
    );
  }

  /// `Cardiology`
  String get department1name {
    return Intl.message(
      'Cardiology',
      name: 'department1name',
      desc: '',
      args: [],
    );
  }

  /// `Profile photo updated successfully.`
  String get profilePhotoUpdateSuccess {
    return Intl.message(
      'Profile photo updated successfully.',
      name: 'profilePhotoUpdateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Linked Accounts`
  String get linkedAccounts {
    return Intl.message(
      'Linked Accounts',
      name: 'linkedAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Newly created doctor account not found`
  String get newlyCreatedDoctorAccountNotFound {
    return Intl.message(
      'Newly created doctor account not found',
      name: 'newlyCreatedDoctorAccountNotFound',
      desc: '',
      args: [],
    );
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
