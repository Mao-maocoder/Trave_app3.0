import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('zh')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Beijing Central Axis China-Peru Civilization Dialogue'**
  String get appTitle;

  /// Greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Chat function
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Search function
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Add function
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Input hint
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get inputHint;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get exitFullscreen;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translating;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @translationResult.
  ///
  /// In en, this message translates to:
  /// **'Translation Result'**
  String get translationResult;

  /// No description provided for @enterTextToTranslate.
  ///
  /// In en, this message translates to:
  /// **'Enter text to translate'**
  String get enterTextToTranslate;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed'**
  String get translationFailed;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @playTranslation.
  ///
  /// In en, this message translates to:
  /// **'Play Translation'**
  String get playTranslation;

  /// No description provided for @swapLanguages.
  ///
  /// In en, this message translates to:
  /// **'Swap Languages'**
  String get swapLanguages;

  /// No description provided for @fromLanguage.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLanguage;

  /// No description provided for @toLanguage.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLanguage;

  /// No description provided for @commonPhrases.
  ///
  /// In en, this message translates to:
  /// **'Common Phrases'**
  String get commonPhrases;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @civilizationExploration.
  ///
  /// In en, this message translates to:
  /// **'Civilization Exploration'**
  String get civilizationExploration;

  /// No description provided for @discoverCivilizationTerms.
  ///
  /// In en, this message translates to:
  /// **'Discover civilization exploration terms and unlock more cultural knowledge!'**
  String get discoverCivilizationTerms;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @switchToChinese.
  ///
  /// In en, this message translates to:
  /// **'Switch to Chinese'**
  String get switchToChinese;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @switchToSpanish.
  ///
  /// In en, this message translates to:
  /// **'Switch to Spanish'**
  String get switchToSpanish;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @applySettings.
  ///
  /// In en, this message translates to:
  /// **'Apply Settings'**
  String get applySettings;

  /// No description provided for @languageSwitched.
  ///
  /// In en, this message translates to:
  /// **'Language switched'**
  String get languageSwitched;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @emergencyService.
  ///
  /// In en, this message translates to:
  /// **'Emergency Service'**
  String get emergencyService;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpRequest.
  ///
  /// In en, this message translates to:
  /// **'Help Request'**
  String get helpRequest;

  /// No description provided for @guideNotified.
  ///
  /// In en, this message translates to:
  /// **'Guide has been notified!'**
  String get guideNotified;

  /// No description provided for @helpFailed.
  ///
  /// In en, this message translates to:
  /// **'Help failed'**
  String get helpFailed;

  /// No description provided for @heatWarning.
  ///
  /// In en, this message translates to:
  /// **'Heat Warning'**
  String get heatWarning;

  /// No description provided for @noHeatWarning.
  ///
  /// In en, this message translates to:
  /// **'No heat warning'**
  String get noHeatWarning;

  /// No description provided for @sendHelpRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Help Request'**
  String get sendHelpRequest;

  /// No description provided for @arCivilizationCodex.
  ///
  /// In en, this message translates to:
  /// **'AR Civilization Codex'**
  String get arCivilizationCodex;

  /// No description provided for @scanSpotsToActivateAR.
  ///
  /// In en, this message translates to:
  /// **'Scan spots to activate AR experience'**
  String get scanSpotsToActivateAR;

  /// No description provided for @viewNow.
  ///
  /// In en, this message translates to:
  /// **'View Now'**
  String get viewNow;

  /// No description provided for @travelHandbook.
  ///
  /// In en, this message translates to:
  /// **'Travel Handbook'**
  String get travelHandbook;

  /// No description provided for @culturalExploration.
  ///
  /// In en, this message translates to:
  /// **'Cultural Exploration'**
  String get culturalExploration;

  /// No description provided for @spotMap.
  ///
  /// In en, this message translates to:
  /// **'Spot Map'**
  String get spotMap;

  /// No description provided for @videoCenter.
  ///
  /// In en, this message translates to:
  /// **'Video Center'**
  String get videoCenter;

  /// No description provided for @photoWall.
  ///
  /// In en, this message translates to:
  /// **'Photo Wall'**
  String get photoWall;

  /// No description provided for @shareYourMemories.
  ///
  /// In en, this message translates to:
  /// **'Share your Central Axis memories'**
  String get shareYourMemories;

  /// No description provided for @smartTranslation.
  ///
  /// In en, this message translates to:
  /// **'Smart Translation'**
  String get smartTranslation;

  /// No description provided for @smartVoiceAssistant.
  ///
  /// In en, this message translates to:
  /// **'Smart Voice Assistant'**
  String get smartVoiceAssistant;

  /// No description provided for @controlYourTravelExperience.
  ///
  /// In en, this message translates to:
  /// **'Control your travel experience with voice'**
  String get controlYourTravelExperience;

  /// No description provided for @tapMicrophoneToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap microphone to start conversation'**
  String get tapMicrophoneToStart;

  /// No description provided for @askYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask your question, AI will reply and play audio automatically'**
  String get askYourQuestion;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @yourFeedbackIsImportant.
  ///
  /// In en, this message translates to:
  /// **'Your feedback is important'**
  String get yourFeedbackIsImportant;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve our service quality and provide better travel experiences for more tourists'**
  String get helpUsImprove;

  /// No description provided for @ratingStandards.
  ///
  /// In en, this message translates to:
  /// **'Rating Standards'**
  String get ratingStandards;

  /// No description provided for @verySatisfied.
  ///
  /// In en, this message translates to:
  /// **'5★: Very satisfied, exceeded expectations'**
  String get verySatisfied;

  /// No description provided for @satisfied.
  ///
  /// In en, this message translates to:
  /// **'4★: Satisfied, met expectations'**
  String get satisfied;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'3★: Average, basically satisfied'**
  String get average;

  /// No description provided for @dissatisfied.
  ///
  /// In en, this message translates to:
  /// **'2★: Dissatisfied, needs improvement'**
  String get dissatisfied;

  /// No description provided for @veryDissatisfied.
  ///
  /// In en, this message translates to:
  /// **'1★: Very dissatisfied'**
  String get veryDissatisfied;

  /// No description provided for @feedbackProcessed.
  ///
  /// In en, this message translates to:
  /// **'We will process your feedback within 24 hours. Excellent feedback will receive rewards!'**
  String get feedbackProcessed;

  /// No description provided for @survey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get survey;

  /// No description provided for @civilizationExplorationSurvey.
  ///
  /// In en, this message translates to:
  /// **'🌟 Civilization Exploration Survey'**
  String get civilizationExplorationSurvey;

  /// No description provided for @surveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Through the \"Triple Civilization Dialogue\" survey, we will assign you a unique explorer identity to help you deeply experience the dialogue between Central Axis attractions and Peruvian civilization.'**
  String get surveyDescription;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information:'**
  String get basicInformation;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender:'**
  String get gender;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group:'**
  String get ageGroup;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income:'**
  String get monthlyIncome;

  /// No description provided for @thankYouForParticipation.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your participation!'**
  String get thankYouForParticipation;

  /// No description provided for @basedOnYourChoices.
  ///
  /// In en, this message translates to:
  /// **'Based on your choices, we have assigned you a unique explorer identity. This will help you better experience the dialogue between Chinese and Peruvian civilizations.'**
  String get basedOnYourChoices;

  /// No description provided for @yourExplorerIdentity.
  ///
  /// In en, this message translates to:
  /// **'Your Explorer Identity:'**
  String get yourExplorerIdentity;

  /// No description provided for @fillSurveyAgain.
  ///
  /// In en, this message translates to:
  /// **'Fill Survey Again'**
  String get fillSurveyAgain;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @exportChat.
  ///
  /// In en, this message translates to:
  /// **'Export Chat'**
  String get exportChat;

  /// No description provided for @chatInfo.
  ///
  /// In en, this message translates to:
  /// **'Chat Info'**
  String get chatInfo;

  /// No description provided for @groupInfo.
  ///
  /// In en, this message translates to:
  /// **'Group Info'**
  String get groupInfo;

  /// No description provided for @addMembers.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get addMembers;

  /// No description provided for @removeMembers.
  ///
  /// In en, this message translates to:
  /// **'Remove Members'**
  String get removeMembers;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @dissolveGroup.
  ///
  /// In en, this message translates to:
  /// **'Dissolve Group'**
  String get dissolveGroup;

  /// No description provided for @changeGroupName.
  ///
  /// In en, this message translates to:
  /// **'Change Group Name'**
  String get changeGroupName;

  /// No description provided for @changeGroupAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Group Avatar'**
  String get changeGroupAvatar;

  /// No description provided for @setGroupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Set Group Admin'**
  String get setGroupAdmin;

  /// No description provided for @removeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get removeAdmin;

  /// No description provided for @transferOwnership.
  ///
  /// In en, this message translates to:
  /// **'Transfer Ownership'**
  String get transferOwnership;

  /// No description provided for @inviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite Link'**
  String get inviteLink;

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLink;

  /// No description provided for @copyInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Link'**
  String get copyInviteLink;

  /// No description provided for @revokeInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Revoke Invite Link'**
  String get revokeInviteLink;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @myQRCode.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get myQRCode;

  /// No description provided for @scanToAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Add Friend'**
  String get scanToAddFriend;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @searchUser.
  ///
  /// In en, this message translates to:
  /// **'Search User'**
  String get searchUser;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @friendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend Request'**
  String get friendRequest;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @sendFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Friend Request'**
  String get sendFriendRequest;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSent;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get friendRequestAccepted;

  /// No description provided for @friendRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected'**
  String get friendRequestRejected;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// No description provided for @friendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed'**
  String get friendRemoved;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlocked;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get userUnblocked;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @userReported.
  ///
  /// In en, this message translates to:
  /// **'User reported'**
  String get userReported;

  /// No description provided for @muteUser.
  ///
  /// In en, this message translates to:
  /// **'Mute User'**
  String get muteUser;

  /// No description provided for @userMuted.
  ///
  /// In en, this message translates to:
  /// **'User muted'**
  String get userMuted;

  /// No description provided for @unmuteUser.
  ///
  /// In en, this message translates to:
  /// **'Unmute User'**
  String get unmuteUser;

  /// No description provided for @userUnmuted.
  ///
  /// In en, this message translates to:
  /// **'User unmuted'**
  String get userUnmuted;

  /// No description provided for @pinChat.
  ///
  /// In en, this message translates to:
  /// **'Pin Chat'**
  String get pinChat;

  /// No description provided for @chatPinned.
  ///
  /// In en, this message translates to:
  /// **'Chat pinned'**
  String get chatPinned;

  /// No description provided for @unpinChat.
  ///
  /// In en, this message translates to:
  /// **'Unpin Chat'**
  String get unpinChat;

  /// No description provided for @chatUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Chat unpinned'**
  String get chatUnpinned;

  /// No description provided for @archiveChat.
  ///
  /// In en, this message translates to:
  /// **'Archive Chat'**
  String get archiveChat;

  /// No description provided for @chatArchived.
  ///
  /// In en, this message translates to:
  /// **'Chat archived'**
  String get chatArchived;

  /// No description provided for @unarchiveChat.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Chat'**
  String get unarchiveChat;

  /// No description provided for @chatUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Chat unarchived'**
  String get chatUnarchived;

  /// No description provided for @deleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat?'**
  String get deleteChatConfirm;

  /// No description provided for @deleteChatWarning.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after deletion'**
  String get deleteChatWarning;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear chat history?'**
  String get clearHistoryConfirm;

  /// No description provided for @clearHistoryWarning.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after clearing'**
  String get clearHistoryWarning;

  /// No description provided for @exportChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to export chat history?'**
  String get exportChatConfirm;

  /// No description provided for @exportChatSuccess.
  ///
  /// In en, this message translates to:
  /// **'Chat history exported successfully'**
  String get exportChatSuccess;

  /// No description provided for @exportChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Chat history export failed'**
  String get exportChatFailed;

  /// No description provided for @chatInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Info'**
  String get chatInfoTitle;

  /// No description provided for @groupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Info'**
  String get groupInfoTitle;

  /// No description provided for @addMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get addMembersTitle;

  /// No description provided for @removeMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Members'**
  String get removeMembersTitle;

  /// No description provided for @leaveGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the group?'**
  String get leaveGroupConfirm;

  /// No description provided for @leaveGroupWarning.
  ///
  /// In en, this message translates to:
  /// **'Cannot rejoin after leaving'**
  String get leaveGroupWarning;

  /// No description provided for @dissolveGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to dissolve the group?'**
  String get dissolveGroupConfirm;

  /// No description provided for @dissolveGroupWarning.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after dissolution'**
  String get dissolveGroupWarning;

  /// No description provided for @changeGroupNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Group Name'**
  String get changeGroupNameTitle;

  /// No description provided for @changeGroupAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Group Avatar'**
  String get changeGroupAvatarTitle;

  /// No description provided for @setGroupAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Group Admin'**
  String get setGroupAdminTitle;

  /// No description provided for @removeAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get removeAdminTitle;

  /// No description provided for @transferOwnershipConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to transfer ownership?'**
  String get transferOwnershipConfirm;

  /// No description provided for @transferOwnershipWarning.
  ///
  /// In en, this message translates to:
  /// **'Cannot be undone after transfer'**
  String get transferOwnershipWarning;

  /// No description provided for @inviteLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Link'**
  String get inviteLinkTitle;

  /// No description provided for @shareInviteLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLinkTitle;

  /// No description provided for @copyInviteLinkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get copyInviteLinkSuccess;

  /// No description provided for @revokeInviteLinkConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke the invite link?'**
  String get revokeInviteLinkConfirm;

  /// No description provided for @revokeInviteLinkWarning.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after revocation'**
  String get revokeInviteLinkWarning;

  /// No description provided for @scanQRCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCodeTitle;

  /// No description provided for @myQRCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get myQRCodeTitle;

  /// No description provided for @scanToAddFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Add Friend'**
  String get scanToAddFriendTitle;

  /// No description provided for @addFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriendTitle;

  /// No description provided for @searchUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Search User'**
  String get searchUserTitle;

  /// No description provided for @userNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFoundMessage;

  /// No description provided for @friendRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend Request'**
  String get friendRequestTitle;

  /// No description provided for @acceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptTitle;

  /// No description provided for @rejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectTitle;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTitle;

  /// No description provided for @acceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get acceptedTitle;

  /// No description provided for @rejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedTitle;

  /// No description provided for @sendFriendRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Friend Request'**
  String get sendFriendRequestTitle;

  /// No description provided for @friendRequestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSentMessage;

  /// No description provided for @friendRequestAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get friendRequestAcceptedMessage;

  /// No description provided for @friendRequestRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected'**
  String get friendRequestRejectedMessage;

  /// No description provided for @removeFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriendTitle;

  /// No description provided for @friendRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Friend removed'**
  String get friendRemovedMessage;

  /// No description provided for @blockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUserTitle;

  /// No description provided for @userBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlockedMessage;

  /// No description provided for @unblockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUserTitle;

  /// No description provided for @userUnblockedMessage.
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get userUnblockedMessage;

  /// No description provided for @reportUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUserTitle;

  /// No description provided for @userReportedMessage.
  ///
  /// In en, this message translates to:
  /// **'User reported'**
  String get userReportedMessage;

  /// No description provided for @muteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Mute User'**
  String get muteUserTitle;

  /// No description provided for @userMutedMessage.
  ///
  /// In en, this message translates to:
  /// **'User muted'**
  String get userMutedMessage;

  /// No description provided for @unmuteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmute User'**
  String get unmuteUserTitle;

  /// No description provided for @userUnmutedMessage.
  ///
  /// In en, this message translates to:
  /// **'User unmuted'**
  String get userUnmutedMessage;

  /// No description provided for @pinChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Pin Chat'**
  String get pinChatTitle;

  /// No description provided for @chatPinnedMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat pinned'**
  String get chatPinnedMessage;

  /// No description provided for @unpinChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpin Chat'**
  String get unpinChatTitle;

  /// No description provided for @chatUnpinnedMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat unpinned'**
  String get chatUnpinnedMessage;

  /// No description provided for @archiveChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Chat'**
  String get archiveChatTitle;

  /// No description provided for @chatArchivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat archived'**
  String get chatArchivedMessage;

  /// No description provided for @unarchiveChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Chat'**
  String get unarchiveChatTitle;

  /// No description provided for @chatUnarchivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat unarchived'**
  String get chatUnarchivedMessage;

  /// No description provided for @deleteChatConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat?'**
  String get deleteChatConfirmTitle;

  /// No description provided for @deleteChatWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after deletion'**
  String get deleteChatWarningMessage;

  /// No description provided for @clearHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear chat history?'**
  String get clearHistoryConfirmTitle;

  /// No description provided for @clearHistoryWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after clearing'**
  String get clearHistoryWarningMessage;

  /// No description provided for @exportChatConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to export chat history?'**
  String get exportChatConfirmTitle;

  /// No description provided for @exportChatSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat history exported successfully'**
  String get exportChatSuccessMessage;

  /// No description provided for @exportChatFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat history export failed'**
  String get exportChatFailedMessage;

  /// No description provided for @chatInfoTitleText.
  ///
  /// In en, this message translates to:
  /// **'Chat Info'**
  String get chatInfoTitleText;

  /// No description provided for @groupInfoTitleText.
  ///
  /// In en, this message translates to:
  /// **'Group Info'**
  String get groupInfoTitleText;

  /// No description provided for @addMembersTitleText.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get addMembersTitleText;

  /// No description provided for @removeMembersTitleText.
  ///
  /// In en, this message translates to:
  /// **'Remove Members'**
  String get removeMembersTitleText;

  /// No description provided for @leaveGroupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the group?'**
  String get leaveGroupConfirmTitle;

  /// No description provided for @leaveGroupWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot rejoin after leaving'**
  String get leaveGroupWarningMessage;

  /// No description provided for @dissolveGroupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to dissolve the group?'**
  String get dissolveGroupConfirmTitle;

  /// No description provided for @dissolveGroupWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after dissolution'**
  String get dissolveGroupWarningMessage;

  /// No description provided for @changeGroupNameTitleText.
  ///
  /// In en, this message translates to:
  /// **'Change Group Name'**
  String get changeGroupNameTitleText;

  /// No description provided for @changeGroupAvatarTitleText.
  ///
  /// In en, this message translates to:
  /// **'Change Group Avatar'**
  String get changeGroupAvatarTitleText;

  /// No description provided for @setGroupAdminTitleText.
  ///
  /// In en, this message translates to:
  /// **'Set Group Admin'**
  String get setGroupAdminTitleText;

  /// No description provided for @removeAdminTitleText.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get removeAdminTitleText;

  /// No description provided for @transferOwnershipConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to transfer ownership?'**
  String get transferOwnershipConfirmTitle;

  /// No description provided for @transferOwnershipWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot be undone after transfer'**
  String get transferOwnershipWarningMessage;

  /// No description provided for @inviteLinkTitleText.
  ///
  /// In en, this message translates to:
  /// **'Invite Link'**
  String get inviteLinkTitleText;

  /// No description provided for @shareInviteLinkTitleText.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLinkTitleText;

  /// No description provided for @copyInviteLinkSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get copyInviteLinkSuccessMessage;

  /// No description provided for @revokeInviteLinkConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke the invite link?'**
  String get revokeInviteLinkConfirmTitle;

  /// No description provided for @revokeInviteLinkWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after revocation'**
  String get revokeInviteLinkWarningMessage;

  /// No description provided for @scanQRCodeTitleText.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCodeTitleText;

  /// No description provided for @myQRCodeTitleText.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get myQRCodeTitleText;

  /// No description provided for @scanToAddFriendTitleText.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Add Friend'**
  String get scanToAddFriendTitleText;

  /// No description provided for @addFriendTitleText.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriendTitleText;

  /// No description provided for @searchUserTitleText.
  ///
  /// In en, this message translates to:
  /// **'Search User'**
  String get searchUserTitleText;

  /// No description provided for @userNotFoundMessageText.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFoundMessageText;

  /// No description provided for @friendRequestTitleText.
  ///
  /// In en, this message translates to:
  /// **'Friend Request'**
  String get friendRequestTitleText;

  /// No description provided for @acceptTitleText.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptTitleText;

  /// No description provided for @rejectTitleText.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectTitleText;

  /// No description provided for @pendingTitleText.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTitleText;

  /// No description provided for @acceptedTitleText.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get acceptedTitleText;

  /// No description provided for @rejectedTitleText.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedTitleText;

  /// No description provided for @sendFriendRequestTitleText.
  ///
  /// In en, this message translates to:
  /// **'Send Friend Request'**
  String get sendFriendRequestTitleText;

  /// No description provided for @friendRequestSentMessageText.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSentMessageText;

  /// No description provided for @friendRequestAcceptedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get friendRequestAcceptedMessageText;

  /// No description provided for @friendRequestRejectedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected'**
  String get friendRequestRejectedMessageText;

  /// No description provided for @removeFriendTitleText.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriendTitleText;

  /// No description provided for @friendRemovedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Friend removed'**
  String get friendRemovedMessageText;

  /// No description provided for @blockUserTitleText.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUserTitleText;

  /// No description provided for @userBlockedMessageText.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlockedMessageText;

  /// No description provided for @unblockUserTitleText.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUserTitleText;

  /// No description provided for @userUnblockedMessageText.
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get userUnblockedMessageText;

  /// No description provided for @reportUserTitleText.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUserTitleText;

  /// No description provided for @userReportedMessageText.
  ///
  /// In en, this message translates to:
  /// **'User reported'**
  String get userReportedMessageText;

  /// No description provided for @muteUserTitleText.
  ///
  /// In en, this message translates to:
  /// **'Mute User'**
  String get muteUserTitleText;

  /// No description provided for @userMutedMessageText.
  ///
  /// In en, this message translates to:
  /// **'User muted'**
  String get userMutedMessageText;

  /// No description provided for @unmuteUserTitleText.
  ///
  /// In en, this message translates to:
  /// **'Unmute User'**
  String get unmuteUserTitleText;

  /// No description provided for @userUnmutedMessageText.
  ///
  /// In en, this message translates to:
  /// **'User unmuted'**
  String get userUnmutedMessageText;

  /// No description provided for @pinChatTitleText.
  ///
  /// In en, this message translates to:
  /// **'Pin Chat'**
  String get pinChatTitleText;

  /// No description provided for @chatPinnedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Chat pinned'**
  String get chatPinnedMessageText;

  /// No description provided for @unpinChatTitleText.
  ///
  /// In en, this message translates to:
  /// **'Unpin Chat'**
  String get unpinChatTitleText;

  /// No description provided for @chatUnpinnedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Chat unpinned'**
  String get chatUnpinnedMessageText;

  /// No description provided for @archiveChatTitleText.
  ///
  /// In en, this message translates to:
  /// **'Archive Chat'**
  String get archiveChatTitleText;

  /// No description provided for @chatArchivedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Chat archived'**
  String get chatArchivedMessageText;

  /// No description provided for @unarchiveChatTitleText.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Chat'**
  String get unarchiveChatTitleText;

  /// No description provided for @chatUnarchivedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Chat unarchived'**
  String get chatUnarchivedMessageText;

  /// No description provided for @deleteChatConfirmTitleText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat?'**
  String get deleteChatConfirmTitleText;

  /// No description provided for @deleteChatWarningMessageText.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after deletion'**
  String get deleteChatWarningMessageText;

  /// No description provided for @clearHistoryConfirmTitleText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear chat history?'**
  String get clearHistoryConfirmTitleText;

  /// No description provided for @clearHistoryWarningMessageText.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered after clearing'**
  String get clearHistoryWarningMessageText;

  /// No description provided for @exportChatConfirmTitleText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to export chat history?'**
  String get exportChatConfirmTitleText;

  /// No description provided for @exportChatSuccessMessageText.
  ///
  /// In en, this message translates to:
  /// **'Chat history exported successfully'**
  String get exportChatSuccessMessageText;

  /// No description provided for @exportChatFailedMessageText.
  ///
  /// In en, this message translates to:
  /// **'Chat history export failed'**
  String get exportChatFailedMessageText;

  /// No description provided for @surveyTitle.
  ///
  /// In en, this message translates to:
  /// **'Civilization Exploration Survey'**
  String get surveyTitle;

  /// No description provided for @surveySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Survey'**
  String get surveySubmit;

  /// No description provided for @surveyReset.
  ///
  /// In en, this message translates to:
  /// **'Fill Again'**
  String get surveyReset;

  /// No description provided for @surveyInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Areas of Interest (Multiple Choice)'**
  String get surveyInterestsTitle;

  /// No description provided for @surveyDietaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences (Multiple Choice)'**
  String get surveyDietaryTitle;

  /// No description provided for @surveyHealthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status:'**
  String get surveyHealthStatus;

  /// No description provided for @surveyHealthStatusDescription.
  ///
  /// In en, this message translates to:
  /// **'Please describe your health status or special needs'**
  String get surveyHealthStatusDescription;

  /// No description provided for @surveyExpectationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Expectations for This Trip (Single Choice)'**
  String get surveyExpectationTitle;

  /// No description provided for @surveySuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Suggestions or Needs'**
  String get surveySuggestionTitle;

  /// No description provided for @surveySuggestionDescription.
  ///
  /// In en, this message translates to:
  /// **'Please share your other suggestions or special needs'**
  String get surveySuggestionDescription;

  /// No description provided for @surveyBasicInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get surveyBasicInfoTitle;

  /// No description provided for @surveyGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get surveyGenderTitle;

  /// No description provided for @surveyAgeGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get surveyAgeGroupTitle;

  /// No description provided for @surveyMonthlyIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get surveyMonthlyIncomeTitle;

  /// No description provided for @surveyCulturalIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Cultural Identity'**
  String get surveyCulturalIdentityTitle;

  /// No description provided for @surveyPsychologicalTraitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Psychological Traits (Multiple Choice)'**
  String get surveyPsychologicalTraitsTitle;

  /// No description provided for @surveyTravelFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Frequency'**
  String get surveyTravelFrequencyTitle;

  /// No description provided for @surveyTripleCivilizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Triple Civilization Dialogue'**
  String get surveyTripleCivilizationTitle;

  /// No description provided for @surveyWoodStoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Wood-Stone Dialogue Preference'**
  String get surveyWoodStoneTitle;

  /// No description provided for @surveyLightCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Light Code Preference'**
  String get surveyLightCodeTitle;

  /// No description provided for @surveyFoodPhilosophyTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Philosophy Preference'**
  String get surveyFoodPhilosophyTitle;

  /// No description provided for @surveyYourIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Explorer Identity'**
  String get surveyYourIdentityTitle;

  /// No description provided for @surveyInterestOption1.
  ///
  /// In en, this message translates to:
  /// **'Chinese Cuisine Culture'**
  String get surveyInterestOption1;

  /// No description provided for @surveyInterestOption2.
  ///
  /// In en, this message translates to:
  /// **'Traditional Folk Experience'**
  String get surveyInterestOption2;

  /// No description provided for @surveyInterestOption3.
  ///
  /// In en, this message translates to:
  /// **'Chinese Language Learning'**
  String get surveyInterestOption3;

  /// No description provided for @surveyInterestOption4.
  ///
  /// In en, this message translates to:
  /// **'Calligraphy & Writing Art'**
  String get surveyInterestOption4;

  /// No description provided for @surveyInterestOption5.
  ///
  /// In en, this message translates to:
  /// **'Chinese Music Culture'**
  String get surveyInterestOption5;

  /// No description provided for @surveyInterestOption6.
  ///
  /// In en, this message translates to:
  /// **'Tea Culture Experience'**
  String get surveyInterestOption6;

  /// No description provided for @surveyInterestOption7.
  ///
  /// In en, this message translates to:
  /// **'Traditional Clothing Culture'**
  String get surveyInterestOption7;

  /// No description provided for @surveyInterestOption8.
  ///
  /// In en, this message translates to:
  /// **'China-Peru Cultural Exchange'**
  String get surveyInterestOption8;

  /// No description provided for @surveyInterestOption9.
  ///
  /// In en, this message translates to:
  /// **'Social Entertainment'**
  String get surveyInterestOption9;

  /// No description provided for @surveyInterestOption10.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get surveyInterestOption10;

  /// No description provided for @surveyDietOption1.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese Cuisine'**
  String get surveyDietOption1;

  /// No description provided for @surveyDietOption2.
  ///
  /// In en, this message translates to:
  /// **'Sichuan Cuisine (Spicy)'**
  String get surveyDietOption2;

  /// No description provided for @surveyDietOption3.
  ///
  /// In en, this message translates to:
  /// **'Cantonese Cuisine (Light)'**
  String get surveyDietOption3;

  /// No description provided for @surveyDietOption4.
  ///
  /// In en, this message translates to:
  /// **'Chinese-Peruvian Fusion'**
  String get surveyDietOption4;

  /// No description provided for @surveyDietOption5.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian Preference'**
  String get surveyDietOption5;

  /// No description provided for @surveyDietOption6.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get surveyDietOption6;

  /// No description provided for @surveyDietOption7.
  ///
  /// In en, this message translates to:
  /// **'Food Allergies'**
  String get surveyDietOption7;

  /// No description provided for @surveyDietOption8.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get surveyDietOption8;

  /// No description provided for @surveyExpectOption1.
  ///
  /// In en, this message translates to:
  /// **'Heritage & Roots Experience'**
  String get surveyExpectOption1;

  /// No description provided for @surveyExpectOption2.
  ///
  /// In en, this message translates to:
  /// **'Deep Cultural Exploration'**
  String get surveyExpectOption2;

  /// No description provided for @surveyExpectOption3.
  ///
  /// In en, this message translates to:
  /// **'Customized Itinerary'**
  String get surveyExpectOption3;

  /// No description provided for @surveyExpectOption4.
  ///
  /// In en, this message translates to:
  /// **'Premium Experience'**
  String get surveyExpectOption4;

  /// No description provided for @surveyExpectOption5.
  ///
  /// In en, this message translates to:
  /// **'Value for Money'**
  String get surveyExpectOption5;

  /// No description provided for @surveyExpectOption6.
  ///
  /// In en, this message translates to:
  /// **'Social Network Expansion'**
  String get surveyExpectOption6;

  /// No description provided for @surveyExpectOption7.
  ///
  /// In en, this message translates to:
  /// **'Identity Exploration'**
  String get surveyExpectOption7;

  /// No description provided for @surveyExpectOption8.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get surveyExpectOption8;

  /// No description provided for @surveyGenderOption1.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get surveyGenderOption1;

  /// No description provided for @surveyGenderOption2.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get surveyGenderOption2;

  /// No description provided for @surveyGenderOption3.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get surveyGenderOption3;

  /// No description provided for @surveyAgeGroupOption1.
  ///
  /// In en, this message translates to:
  /// **'18-25 years'**
  String get surveyAgeGroupOption1;

  /// No description provided for @surveyAgeGroupOption2.
  ///
  /// In en, this message translates to:
  /// **'26-30 years'**
  String get surveyAgeGroupOption2;

  /// No description provided for @surveyAgeGroupOption3.
  ///
  /// In en, this message translates to:
  /// **'31-35 years'**
  String get surveyAgeGroupOption3;

  /// No description provided for @surveyAgeGroupOption4.
  ///
  /// In en, this message translates to:
  /// **'36-40 years'**
  String get surveyAgeGroupOption4;

  /// No description provided for @surveyAgeGroupOption5.
  ///
  /// In en, this message translates to:
  /// **'40+ years'**
  String get surveyAgeGroupOption5;

  /// No description provided for @surveyIncomeOption1.
  ///
  /// In en, this message translates to:
  /// **'Below 10,000 Soles'**
  String get surveyIncomeOption1;

  /// No description provided for @surveyIncomeOption2.
  ///
  /// In en, this message translates to:
  /// **'10,000-20,000 Soles'**
  String get surveyIncomeOption2;

  /// No description provided for @surveyIncomeOption3.
  ///
  /// In en, this message translates to:
  /// **'20,000-30,000 Soles'**
  String get surveyIncomeOption3;

  /// No description provided for @surveyIncomeOption4.
  ///
  /// In en, this message translates to:
  /// **'Above 30,000 Soles'**
  String get surveyIncomeOption4;

  /// No description provided for @surveyIdentityOption1.
  ///
  /// In en, this message translates to:
  /// **'More Chinese Cultural Identity'**
  String get surveyIdentityOption1;

  /// No description provided for @surveyIdentityOption2.
  ///
  /// In en, this message translates to:
  /// **'More Peruvian Cultural Identity'**
  String get surveyIdentityOption2;

  /// No description provided for @surveyIdentityOption3.
  ///
  /// In en, this message translates to:
  /// **'Peruvian-Chinese Hybrid Identity'**
  String get surveyIdentityOption3;

  /// No description provided for @surveyIdentityOption4.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous Identity'**
  String get surveyIdentityOption4;

  /// No description provided for @surveyPsychologicalOption1.
  ///
  /// In en, this message translates to:
  /// **'Emotional Connection to Ancestral Country'**
  String get surveyPsychologicalOption1;

  /// No description provided for @surveyPsychologicalOption2.
  ///
  /// In en, this message translates to:
  /// **'Cultural Identity Confusion'**
  String get surveyPsychologicalOption2;

  /// No description provided for @surveyPsychologicalOption3.
  ///
  /// In en, this message translates to:
  /// **'Career Choices Influenced by Generations'**
  String get surveyPsychologicalOption3;

  /// No description provided for @surveyPsychologicalOption4.
  ///
  /// In en, this message translates to:
  /// **'Strong Adaptability to Uncertainty'**
  String get surveyPsychologicalOption4;

  /// No description provided for @surveyPsychologicalOption5.
  ///
  /// In en, this message translates to:
  /// **'Easily Influenced by Parents'**
  String get surveyPsychologicalOption5;

  /// No description provided for @surveyPsychologicalOption6.
  ///
  /// In en, this message translates to:
  /// **'Value Friend Recommendations'**
  String get surveyPsychologicalOption6;

  /// No description provided for @surveyFrequencyOption1.
  ///
  /// In en, this message translates to:
  /// **'Multiple times per year'**
  String get surveyFrequencyOption1;

  /// No description provided for @surveyFrequencyOption2.
  ///
  /// In en, this message translates to:
  /// **'Once per year'**
  String get surveyFrequencyOption2;

  /// No description provided for @surveyFrequencyOption3.
  ///
  /// In en, this message translates to:
  /// **'Every 2-3 years'**
  String get surveyFrequencyOption3;

  /// No description provided for @surveyFrequencyOption4.
  ///
  /// In en, this message translates to:
  /// **'Rarely travel'**
  String get surveyFrequencyOption4;

  /// No description provided for @surveyWoodStoneOption1.
  ///
  /// In en, this message translates to:
  /// **'Forbidden City Mortise-Tenon'**
  String get surveyWoodStoneOption1;

  /// No description provided for @surveyWoodStoneOption2.
  ///
  /// In en, this message translates to:
  /// **'Machu Picchu Stone Technology'**
  String get surveyWoodStoneOption2;

  /// No description provided for @surveyWoodStoneOption3.
  ///
  /// In en, this message translates to:
  /// **'Both Interested'**
  String get surveyWoodStoneOption3;

  /// No description provided for @surveyWoodStoneOption4.
  ///
  /// In en, this message translates to:
  /// **'Focus on Architectural Beauty'**
  String get surveyWoodStoneOption4;

  /// No description provided for @surveyLightCodeOption1.
  ///
  /// In en, this message translates to:
  /// **'Qianqing Palace Sunlight'**
  String get surveyLightCodeOption1;

  /// No description provided for @surveyLightCodeOption2.
  ///
  /// In en, this message translates to:
  /// **'Inca Sun Temple'**
  String get surveyLightCodeOption2;

  /// No description provided for @surveyLightCodeOption3.
  ///
  /// In en, this message translates to:
  /// **'Astronomical Calendar Comparison'**
  String get surveyLightCodeOption3;

  /// No description provided for @surveyLightCodeOption4.
  ///
  /// In en, this message translates to:
  /// **'Focus on Time Codes'**
  String get surveyLightCodeOption4;

  /// No description provided for @surveyFoodPhilosophyOption1.
  ///
  /// In en, this message translates to:
  /// **'Siheyuan Chinese-Peruvian Feast'**
  String get surveyFoodPhilosophyOption1;

  /// No description provided for @surveyFoodPhilosophyOption2.
  ///
  /// In en, this message translates to:
  /// **'Andes Traditional Ingredients'**
  String get surveyFoodPhilosophyOption2;

  /// No description provided for @surveyFoodPhilosophyOption3.
  ///
  /// In en, this message translates to:
  /// **'Food Culture Fusion'**
  String get surveyFoodPhilosophyOption3;

  /// No description provided for @surveyFoodPhilosophyOption4.
  ///
  /// In en, this message translates to:
  /// **'Focus on Ingredient Stories'**
  String get surveyFoodPhilosophyOption4;

  /// No description provided for @surveyRoleWoodMaster.
  ///
  /// In en, this message translates to:
  /// **'Architectural Master'**
  String get surveyRoleWoodMaster;

  /// No description provided for @surveyRoleWoodMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Expert in wood and stone structures, skilled at discovering architectural wisdom codes'**
  String get surveyRoleWoodMasterDesc;

  /// No description provided for @surveyRoleLightPoet.
  ///
  /// In en, this message translates to:
  /// **'Light Poet'**
  String get surveyRoleLightPoet;

  /// No description provided for @surveyRoleLightPoetDesc.
  ///
  /// In en, this message translates to:
  /// **'Sensitive to light and shadow changes, able to decode light codes in time and space'**
  String get surveyRoleLightPoetDesc;

  /// No description provided for @surveyRoleFoodPhilosopher.
  ///
  /// In en, this message translates to:
  /// **'Food Philosopher'**
  String get surveyRoleFoodPhilosopher;

  /// No description provided for @surveyRoleFoodPhilosopherDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep understanding of food culture, able to read civilization stories from ingredients'**
  String get surveyRoleFoodPhilosopherDesc;

  /// No description provided for @surveyRoleCulturalExplorer.
  ///
  /// In en, this message translates to:
  /// **'Civilization Explorer'**
  String get surveyRoleCulturalExplorer;

  /// No description provided for @surveyRoleCulturalExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive explorer, skilled at discovering dialogues between civilizations'**
  String get surveyRoleCulturalExplorerDesc;

  /// No description provided for @surveySwitchLocale.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get surveySwitchLocale;

  /// No description provided for @surveyBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'🌟 Civilization Exploration Survey'**
  String get surveyBannerTitle;

  /// No description provided for @surveyBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'Through the \"Triple Civilization Dialogue\" themed survey, we will assign you a unique explorer identity, allowing you to deeply experience the dialogue between Beijing Central Axis attractions and Peruvian civilization.'**
  String get surveyBannerDescription;

  /// No description provided for @surveyThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your participation!'**
  String get surveyThankYou;

  /// No description provided for @surveyResultDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on your choices, we have assigned you a unique explorer identity. This will help you better experience the dialogue between Chinese and Peruvian civilizations.'**
  String get surveyResultDescription;

  /// No description provided for @surveyFillAgain.
  ///
  /// In en, this message translates to:
  /// **'Fill Survey Again'**
  String get surveyFillAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
