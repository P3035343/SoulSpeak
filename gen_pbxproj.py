#!/usr/bin/env python3
import hashlib, os

def make_id(seed):
    return hashlib.md5(seed.encode()).hexdigest()[:24].upper()

files = [
    'App/ContentView.swift',
    'App/MainTabView.swift',
    'App/SoulSpeakApp.swift',
    'Models/AccountabilityCategory.swift',
    'Models/JournalEntry.swift',
    'Models/MoodEntry.swift',
    'Models/UserProfile.swift',
    'Models/UserSettings.swift',
    'Services/AudioPlayerService.swift',
    'Services/CheckInService.swift',
    'Services/DrHopeResponseEngine.swift',
    'Services/EmergencyService.swift',
    'Services/GeminiService.swift',
    'Services/NotificationService.swift',
    'Services/ScriptureService.swift',
    'Services/SpeechRecognitionService.swift',
    'Services/StoreKitService.swift',
    'Services/TextToSpeechService.swift',
    'Services/VoiceRecorderService.swift',
    'Theme/SoulSpeakTheme.swift',
    'Views/Analytics/AnalyticsView.swift',
    'Views/Centered/CenteredView.swift',
    'Views/Centered/MeditationCatalogView.swift',
    'Views/Centered/SoundscapesView.swift',
    'Views/Components/AccountabilityCategoriesView.swift',
    'Views/Components/ConversationView.swift',
    'Views/Components/EmergencyView.swift',
    'Views/Components/MainHubView.swift',
    'Views/Components/PaywallView.swift',
    'Views/MoodTracker/MoodTrackerView.swift',
    'Views/Prayer/PrayerOutroView.swift',
    'Views/Settings/SettingsView.swift',
    'Views/VentRoom/DestructionRoomView.swift',
    'Views/VentRoom/PaperBurnView.swift',
    'Views/VentRoom/RageRoomSceneManager.swift',
    'Views/VentRoom/ReleaseView.swift',
    'Views/VentRoom/VentPlaybackView.swift',
    'Views/VentRoom/VentRecordingView.swift',
    'Views/VentRoom/VentRoomView.swift',
    'Views/VoiceJournal/DrHopeListeningView.swift',
    'Views/VoiceJournal/VoiceJournalView.swift',
    'Views/VoiceJournal/WaveformView.swift',
    'Views/Welcome/DisclaimerView.swift',
    'Views/Welcome/IntroSequenceView.swift',
    'Views/Welcome/VideoPlayerView.swift',
    'Views/Welcome/WelcomeView.swift',
]


groups_def = {
    'App': ['ContentView.swift', 'MainTabView.swift', 'SoulSpeakApp.swift'],
    'Models': ['AccountabilityCategory.swift', 'JournalEntry.swift', 'MoodEntry.swift', 'UserProfile.swift', 'UserSettings.swift'],
    'Services': ['AudioPlayerService.swift', 'CheckInService.swift', 'DrHopeResponseEngine.swift', 'EmergencyService.swift', 'GeminiService.swift', 'NotificationService.swift', 'ScriptureService.swift', 'SpeechRecognitionService.swift', 'StoreKitService.swift', 'TextToSpeechService.swift', 'VoiceRecorderService.swift'],
    'Theme': ['SoulSpeakTheme.swift'],
    'Views/Analytics': ['AnalyticsView.swift'],
    'Views/Centered': ['CenteredView.swift', 'MeditationCatalogView.swift', 'SoundscapesView.swift'],
    'Views/Components': ['AccountabilityCategoriesView.swift', 'ConversationView.swift', 'EmergencyView.swift', 'MainHubView.swift', 'PaywallView.swift'],
    'Views/MoodTracker': ['MoodTrackerView.swift'],
    'Views/Prayer': ['PrayerOutroView.swift'],
    'Views/Settings': ['SettingsView.swift'],
    'Views/VentRoom': ['DestructionRoomView.swift', 'PaperBurnView.swift', 'RageRoomSceneManager.swift', 'ReleaseView.swift', 'VentPlaybackView.swift', 'VentRecordingView.swift', 'VentRoomView.swift'],
    'Views/VoiceJournal': ['DrHopeListeningView.swift', 'VoiceJournalView.swift', 'WaveformView.swift'],
    'Views/Welcome': ['DisclaimerView.swift', 'IntroSequenceView.swift', 'VideoPlayerView.swift', 'WelcomeView.swift'],
}

# IDs
MAIN_GROUP = make_id("maingroup")
PRODUCTS_GROUP = make_id("productsgroup")
SOULSPEAK_GROUP = make_id("group_SoulSpeak")
VIEWS_GROUP = make_id("group_Views")
PRODUCT_REF = make_id("productref")
TARGET = make_id("target")
PROJECT = make_id("project")
SOURCES_PHASE = make_id("sourcesphase")
RESOURCES_PHASE = make_id("resourcesphase")
FRAMEWORKS_PHASE = make_id("frameworksphase")
DEBUG_PROJ = make_id("debug_project")
RELEASE_PROJ = make_id("release_project")
DEBUG_TARG = make_id("debug_target")
RELEASE_TARG = make_id("release_target")
PROJ_CONFIG_LIST = make_id("configlist_project")
TARG_CONFIG_LIST = make_id("configlist_target")
ASSETS_FREF = make_id("fref_Assets.xcassets")
ASSETS_BREF = make_id("bref_Assets.xcassets")
INFO_FREF = make_id("fref_Info.plist")


out = []
out.append('// !$*UTF8*$!')
out.append('{')
out.append('\tarchiveVersion = 1;')
out.append('\tclasses = {')
out.append('\t};')
out.append('\tobjectVersion = 56;')
out.append('\tobjects = {')
out.append('')

# PBXBuildFile section
out.append('/* Begin PBXBuildFile section */')
for f in files:
    bref = make_id(f'bref_{f}')
    fref = make_id(f'fref_{f}')
    name = os.path.basename(f)
    out.append(f'\t\t{bref} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fref}; }};')
# Assets build file
out.append(f'\t\t{ASSETS_BREF} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ASSETS_FREF}; }};')
out.append('/* End PBXBuildFile section */')
out.append('')

# PBXFileReference section
out.append('/* Begin PBXFileReference section */')
for f in files:
    fref = make_id(f'fref_{f}')
    name = os.path.basename(f)
    out.append(f'\t\t{fref} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = "<group>"; }};')
out.append(f'\t\t{ASSETS_FREF} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
out.append(f'\t\t{INFO_FREF} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
out.append(f'\t\t{PRODUCT_REF} /* SoulSpeak.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = SoulSpeak.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
out.append('/* End PBXFileReference section */')
out.append('')


# PBXFrameworksBuildPhase
out.append('/* Begin PBXFrameworksBuildPhase section */')
out.append(f'\t\t{FRAMEWORKS_PHASE} /* Frameworks */ = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};')
out.append('/* End PBXFrameworksBuildPhase section */')
out.append('')

# PBXGroup section
out.append('/* Begin PBXGroup section */')

# Main group
out.append(f'\t\t{MAIN_GROUP} = {{')
out.append(f'\t\t\tisa = PBXGroup;')
out.append(f'\t\t\tchildren = (')
out.append(f'\t\t\t\t{SOULSPEAK_GROUP} /* SoulSpeak */,')
out.append(f'\t\t\t\t{PRODUCTS_GROUP} /* Products */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tsourceTree = "<group>";')
out.append(f'\t\t}};')

# Products group
out.append(f'\t\t{PRODUCTS_GROUP} /* Products */ = {{')
out.append(f'\t\t\tisa = PBXGroup;')
out.append(f'\t\t\tchildren = (')
out.append(f'\t\t\t\t{PRODUCT_REF} /* SoulSpeak.app */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tname = Products;')
out.append(f'\t\t\tsourceTree = "<group>";')
out.append(f'\t\t}};')

# SoulSpeak group (top-level folder)
top_groups = ['App', 'Models', 'Services', 'Theme']
top_group_ids = [make_id(f'group_{g}') for g in top_groups]
out.append(f'\t\t{SOULSPEAK_GROUP} /* SoulSpeak */ = {{')
out.append(f'\t\t\tisa = PBXGroup;')
out.append(f'\t\t\tchildren = (')
for gid in top_group_ids:
    out.append(f'\t\t\t\t{gid},')
out.append(f'\t\t\t\t{VIEWS_GROUP} /* Views */,')
out.append(f'\t\t\t\t{ASSETS_FREF} /* Assets.xcassets */,')
out.append(f'\t\t\t\t{INFO_FREF} /* Info.plist */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tpath = SoulSpeak;')
out.append(f'\t\t\tsourceTree = "<group>";')
out.append(f'\t\t}};')


# Top-level groups (App, Models, Services, Theme)
for g in top_groups:
    gid = make_id(f'group_{g}')
    children = groups_def[g]
    out.append(f'\t\t{gid} /* {g} */ = {{')
    out.append(f'\t\t\tisa = PBXGroup;')
    out.append(f'\t\t\tchildren = (')
    for child in children:
        fref = make_id(f'fref_{g}/{child}')
        out.append(f'\t\t\t\t{fref} /* {child} */,')
    out.append(f'\t\t\t);')
    out.append(f'\t\t\tpath = {g};')
    out.append(f'\t\t\tsourceTree = "<group>";')
    out.append(f'\t\t}};')

# Views group
view_subgroups = ['Views/Analytics', 'Views/Centered', 'Views/Components', 'Views/MoodTracker', 'Views/Prayer', 'Views/Settings', 'Views/VentRoom', 'Views/VoiceJournal', 'Views/Welcome']
out.append(f'\t\t{VIEWS_GROUP} /* Views */ = {{')
out.append(f'\t\t\tisa = PBXGroup;')
out.append(f'\t\t\tchildren = (')
for vg in view_subgroups:
    vgid = make_id(f'group_{vg}')
    out.append(f'\t\t\t\t{vgid} /* {vg.split("/")[1]} */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tpath = Views;')
out.append(f'\t\t\tsourceTree = "<group>";')
out.append(f'\t\t}};')

# View sub-groups
for vg in view_subgroups:
    vgid = make_id(f'group_{vg}')
    folder_name = vg.split('/')[1]
    children = groups_def[vg]
    out.append(f'\t\t{vgid} /* {folder_name} */ = {{')
    out.append(f'\t\t\tisa = PBXGroup;')
    out.append(f'\t\t\tchildren = (')
    for child in children:
        fref = make_id(f'fref_{vg}/{child}')
        out.append(f'\t\t\t\t{fref} /* {child} */,')
    out.append(f'\t\t\t);')
    out.append(f'\t\t\tpath = {folder_name};')
    out.append(f'\t\t\tsourceTree = "<group>";')
    out.append(f'\t\t}};')

out.append('/* End PBXGroup section */')
out.append('')


# PBXNativeTarget
out.append('/* Begin PBXNativeTarget section */')
out.append(f'\t\t{TARGET} /* SoulSpeak */ = {{')
out.append(f'\t\t\tisa = PBXNativeTarget;')
out.append(f'\t\t\tbuildConfigurationList = {TARG_CONFIG_LIST};')
out.append(f'\t\t\tbuildPhases = (')
out.append(f'\t\t\t\t{SOURCES_PHASE} /* Sources */,')
out.append(f'\t\t\t\t{FRAMEWORKS_PHASE} /* Frameworks */,')
out.append(f'\t\t\t\t{RESOURCES_PHASE} /* Resources */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tbuildRules = ();')
out.append(f'\t\t\tdependencies = ();')
out.append(f'\t\t\tname = SoulSpeak;')
out.append(f'\t\t\tproductName = SoulSpeak;')
out.append(f'\t\t\tproductReference = {PRODUCT_REF} /* SoulSpeak.app */;')
out.append(f'\t\t\tproductType = "com.apple.product-type.application";')
out.append(f'\t\t}};')
out.append('/* End PBXNativeTarget section */')
out.append('')

# PBXProject
out.append('/* Begin PBXProject section */')
out.append(f'\t\t{PROJECT} /* Project object */ = {{')
out.append(f'\t\t\tisa = PBXProject;')
out.append(f'\t\t\tattributes = {{')
out.append(f'\t\t\t\tBuildIndependentTargetsInParallel = 1;')
out.append(f'\t\t\t\tLastSwiftUpdateCheck = 1520;')
out.append(f'\t\t\t\tLastUpgradeCheck = 1520;')
out.append(f'\t\t\t\tTargetAttributes = {{')
out.append(f'\t\t\t\t\t{TARGET} = {{')
out.append(f'\t\t\t\t\t\tCreatedOnToolsVersion = 15.2;')
out.append(f'\t\t\t\t\t}};')
out.append(f'\t\t\t\t}};')
out.append(f'\t\t\t}};')
out.append(f'\t\t\tbuildConfigurationList = {PROJ_CONFIG_LIST};')
out.append(f'\t\t\tcompatibilityVersion = "Xcode 14.0";')
out.append(f'\t\t\tdevelopmentRegion = en;')
out.append(f'\t\t\thasScannedForEncodings = 0;')
out.append(f'\t\t\tknownRegions = (')
out.append(f'\t\t\t\ten,')
out.append(f'\t\t\t\tBase,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tmainGroup = {MAIN_GROUP};')
out.append(f'\t\t\tproductRefGroup = {PRODUCTS_GROUP} /* Products */;')
out.append(f'\t\t\tprojectDirPath = "";')
out.append(f'\t\t\tprojectRoot = "";')
out.append(f'\t\t\ttargets = (')
out.append(f'\t\t\t\t{TARGET} /* SoulSpeak */,')
out.append(f'\t\t\t);')
out.append(f'\t\t}};')
out.append('/* End PBXProject section */')
out.append('')


# PBXResourcesBuildPhase
out.append('/* Begin PBXResourcesBuildPhase section */')
out.append(f'\t\t{RESOURCES_PHASE} /* Resources */ = {{')
out.append(f'\t\t\tisa = PBXResourcesBuildPhase;')
out.append(f'\t\t\tbuildActionMask = 2147483647;')
out.append(f'\t\t\tfiles = (')
out.append(f'\t\t\t\t{ASSETS_BREF} /* Assets.xcassets in Resources */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append(f'\t\t}};')
out.append('/* End PBXResourcesBuildPhase section */')
out.append('')

# PBXSourcesBuildPhase
out.append('/* Begin PBXSourcesBuildPhase section */')
out.append(f'\t\t{SOURCES_PHASE} /* Sources */ = {{')
out.append(f'\t\t\tisa = PBXSourcesBuildPhase;')
out.append(f'\t\t\tbuildActionMask = 2147483647;')
out.append(f'\t\t\tfiles = (')
for f in files:
    bref = make_id(f'bref_{f}')
    name = os.path.basename(f)
    out.append(f'\t\t\t\t{bref} /* {name} in Sources */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append(f'\t\t}};')
out.append('/* End PBXSourcesBuildPhase section */')
out.append('')


# XCBuildConfiguration
out.append('/* Begin XCBuildConfiguration section */')

# Debug - Project level
out.append(f'\t\t{DEBUG_PROJ} /* Debug */ = {{')
out.append(f'\t\t\tisa = XCBuildConfiguration;')
out.append(f'\t\t\tbuildSettings = {{')
out.append(f'\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
out.append(f'\t\t\t\tCLANG_ENABLE_MODULES = YES;')
out.append(f'\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
out.append(f'\t\t\t\tCOPY_PHASE_STRIP = NO;')
out.append(f'\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
out.append(f'\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
out.append(f'\t\t\t\tENABLE_TESTABILITY = YES;')
out.append(f'\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;')
out.append(f'\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
out.append(f'\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
out.append(f'\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
out.append(f'\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (')
out.append(f'\t\t\t\t\t"DEBUG=1",')
out.append(f'\t\t\t\t\t"$(inherited)",')
out.append(f'\t\t\t\t);')
out.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
out.append(f'\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
out.append(f'\t\t\t\tMTL_FAST_MATH = YES;')
out.append(f'\t\t\t\tONLY_ACTIVE_ARCH = YES;')
out.append(f'\t\t\t\tSDKROOT = iphoneos;')
out.append(f'\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";')
out.append(f'\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
out.append(f'\t\t\t}};')
out.append(f'\t\t\tname = Debug;')
out.append(f'\t\t}};')

# Release - Project level
out.append(f'\t\t{RELEASE_PROJ} /* Release */ = {{')
out.append(f'\t\t\tisa = XCBuildConfiguration;')
out.append(f'\t\t\tbuildSettings = {{')
out.append(f'\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
out.append(f'\t\t\t\tCLANG_ENABLE_MODULES = YES;')
out.append(f'\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
out.append(f'\t\t\t\tCOPY_PHASE_STRIP = NO;')
out.append(f'\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
out.append(f'\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
out.append(f'\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
out.append(f'\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;')
out.append(f'\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
out.append(f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
out.append(f'\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
out.append(f'\t\t\t\tMTL_FAST_MATH = YES;')
out.append(f'\t\t\t\tSDKROOT = iphoneos;')
out.append(f'\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
out.append(f'\t\t\t\tVALIDATE_PRODUCT = YES;')
out.append(f'\t\t\t}};')
out.append(f'\t\t\tname = Release;')
out.append(f'\t\t}};')


# Debug - Target level
out.append(f'\t\t{DEBUG_TARG} /* Debug */ = {{')
out.append(f'\t\t\tisa = XCBuildConfiguration;')
out.append(f'\t\t\tbuildSettings = {{')
out.append(f'\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
out.append(f'\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
out.append(f'\t\t\t\tCODE_SIGN_STYLE = Automatic;')
out.append(f'\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
out.append(f'\t\t\t\tDEVELOPMENT_TEAM = "";')
out.append(f'\t\t\t\tENABLE_PREVIEWS = YES;')
out.append(f'\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
out.append(f'\t\t\t\tINFOPLIST_FILE = SoulSpeak/Info.plist;')
out.append(f'\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = SoulSpeak;')
out.append(f'\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
out.append(f'\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
out.append(f'\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;')
out.append(f'\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
out.append(f'\t\t\t\t\t"$(inherited)",')
out.append(f'\t\t\t\t\t"@executable_path/Frameworks",')
out.append(f'\t\t\t\t);')
out.append(f'\t\t\t\tMARKETING_VERSION = 1.0.0;')
out.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.soulspeak.app;')
out.append(f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
out.append(f'\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
out.append(f'\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
out.append(f'\t\t\t\tSWIFT_VERSION = 5.0;')
out.append(f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
out.append(f'\t\t\t}};')
out.append(f'\t\t\tname = Debug;')
out.append(f'\t\t}};')

# Release - Target level
out.append(f'\t\t{RELEASE_TARG} /* Release */ = {{')
out.append(f'\t\t\tisa = XCBuildConfiguration;')
out.append(f'\t\t\tbuildSettings = {{')
out.append(f'\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
out.append(f'\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
out.append(f'\t\t\t\tCODE_SIGN_STYLE = Automatic;')
out.append(f'\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
out.append(f'\t\t\t\tDEVELOPMENT_TEAM = "";')
out.append(f'\t\t\t\tENABLE_PREVIEWS = YES;')
out.append(f'\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
out.append(f'\t\t\t\tINFOPLIST_FILE = SoulSpeak/Info.plist;')
out.append(f'\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = SoulSpeak;')
out.append(f'\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
out.append(f'\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
out.append(f'\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;')
out.append(f'\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
out.append(f'\t\t\t\t\t"$(inherited)",')
out.append(f'\t\t\t\t\t"@executable_path/Frameworks",')
out.append(f'\t\t\t\t);')
out.append(f'\t\t\t\tMARKETING_VERSION = 1.0.0;')
out.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.soulspeak.app;')
out.append(f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
out.append(f'\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
out.append(f'\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
out.append(f'\t\t\t\tSWIFT_VERSION = 5.0;')
out.append(f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
out.append(f'\t\t\t}};')
out.append(f'\t\t\tname = Release;')
out.append(f'\t\t}};')

out.append('/* End XCBuildConfiguration section */')
out.append('')


# XCConfigurationList
out.append('/* Begin XCConfigurationList section */')
out.append(f'\t\t{PROJ_CONFIG_LIST} /* Build configuration list for PBXProject */ = {{')
out.append(f'\t\t\tisa = XCConfigurationList;')
out.append(f'\t\t\tbuildConfigurations = (')
out.append(f'\t\t\t\t{DEBUG_PROJ} /* Debug */,')
out.append(f'\t\t\t\t{RELEASE_PROJ} /* Release */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tdefaultConfigurationIsVisible = 0;')
out.append(f'\t\t\tdefaultConfigurationName = Release;')
out.append(f'\t\t}};')
out.append(f'\t\t{TARG_CONFIG_LIST} /* Build configuration list for PBXNativeTarget */ = {{')
out.append(f'\t\t\tisa = XCConfigurationList;')
out.append(f'\t\t\tbuildConfigurations = (')
out.append(f'\t\t\t\t{DEBUG_TARG} /* Debug */,')
out.append(f'\t\t\t\t{RELEASE_TARG} /* Release */,')
out.append(f'\t\t\t);')
out.append(f'\t\t\tdefaultConfigurationIsVisible = 0;')
out.append(f'\t\t\tdefaultConfigurationName = Release;')
out.append(f'\t\t}};')
out.append('/* End XCConfigurationList section */')
out.append('')

# Close
out.append('\t};')
out.append(f'\trootObject = {PROJECT} /* Project object */;')
out.append('}')

# Write the file
output = '\n'.join(out) + '\n'
with open('SoulSpeak.xcodeproj/project.pbxproj', 'w') as f:
    f.write(output)

print(f"Generated project.pbxproj with {len(files)} source files")
print("All files included in Sources build phase")
