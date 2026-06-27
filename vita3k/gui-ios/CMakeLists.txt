cmake_minimum_required(VERSION 3.16...3.25)

project(Vion C CXX OBJC Swift)

set(TEAM "Z3ZEABYY6P" CACHE STRING "IDENTIFIER")

set(SWIFT_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Classes/BaseGame.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Classes/Cell.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Classes/Game.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Classes/GameDetails.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Classes/ThumbstickView.swift"

    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Controllers/EmulationController.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Controllers/GamesController.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Controllers/TabController.swift"

    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Extensions/RangeReplaceableCollection.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Extensions/Sequence.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Extensions/UIButton.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Extensions/UIView.swift"

    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Structs/CellManager.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Structs/LayoutManager.swift"

    "${CMAKE_CURRENT_SOURCE_DIR}/swift/AppDelegate.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/SceneDelegate.swift"
)

set(SWIFT_PACKAGE_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/ConstraintKit/ConstraintKit.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/OBController.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/Classes/OBListCell.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/OnboardingKit.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/Structs/OBControllerConfiguration.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/Structs/CellConfiguration.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/Structs/LabelConfiguration.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/Structs/MeshGradientView.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/Structs/OBControllerWithListConfiguration.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/OnboardingKit/OBControllerWithList.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/AntiqueKit/AntiqueKit.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/FontKit/UIFont.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/SettingsKit/SettingHeader.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/SettingsKit/SettingsKit.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/SettingsKit/SettingDelegate.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/SettingsKit/SettingTypes.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/ColourKit/Colour.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages/ColourKit/Color.swift"
)

add_executable(Vion ${SWIFT_SOURCES} ${SWIFT_PACKAGE_SOURCES})

set_target_properties(Vion PROPERTIES
    MACOSX_BUNDLE TRUE

    MACOSX_BUNDLE_GUI_IDENTIFIER "com.antique.Vion"
    MACOSX_BUNDLE_BUNDLE_NAME "Vion"
    MACOSX_BUNDLE_BUNDLE_VERSION "9"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
    MACOSX_BUNDLE_EXECUTABLE_NAME "Vion"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"

    XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION "9"
    XCODE_ATTRIBUTE_MARKETING_VERSION "1.0"

    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.antique.Vion"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1"

    XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "16.0"
    XCODE_ATTRIBUTE_INSTALL_PATH "/Applications"

    XCODE_ATTRIBUTE_SDKROOT "${CMAKE_OSX_SYSROOT}"

    XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Automatic"
    XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${TEAM}"

    XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/Vion.entitlements"

    XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/../ios_bridge.h"
    XCODE_ATTRIBUTE_SWIFT_OBJC_INTEROP_MODE "objcxx"
    XCODE_ATTRIBUTE_SWIFT_VERSION "6.0"
    XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/Frameworks"

    XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "App Icon"

    XCODE_ATTRIBUTE_INFOPLIST_KEY_LSApplicationCategoryType "public.app-category.entertainment"

    XCODE_ATTRIBUTE_GENERATE_INFOPLIST_FILE TRUE
)

target_link_libraries(Vion PUBLIC
    config
    ctrl
    dialog
    emuenv
    app
    compat
    io
    np
    kernel
    motion
    packages
    renderer
    touch
    gxm
    audio
    ime

    vita3k
)

source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/swift/Packages" PREFIX "Packages" FILES ${SWIFT_PACKAGE_SOURCES})
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/swift" PREFIX "Swift" FILES ${SWIFT_SOURCES})

set(FFMPEG_AVFORMAT_XCFRAMEWORK "${CMAKE_BINARY_DIR}/external/ffmpeg/lib/libavformat.xcframework")
set(FFMPEG_AVCODEC_XCFRAMEWORK "${CMAKE_BINARY_DIR}/external/ffmpeg/lib/libavcodec.xcframework")
set(FFMPEG_SWSCALE_XCFRAMEWORK "${CMAKE_BINARY_DIR}/external/ffmpeg/lib/libswscale.xcframework")
set(FFMPEG_AVUTIL_XCFRAMEWORK "${CMAKE_BINARY_DIR}/external/ffmpeg/lib/libavutil.xcframework")
set(FFMPEG_AVFILTER_XCFRAMEWORK "${CMAKE_BINARY_DIR}/external/ffmpeg/lib/libavfilter.xcframework")
set(FFMPEG_SWRESAMPLE_XCFRAMEWORK "${CMAKE_BINARY_DIR}/external/ffmpeg/lib/libswresample.xcframework")

set_target_properties(Vion PROPERTIES
    XCODE_EMBED_FRAMEWORKS "${MOLTENVK_XCFRAMEWORK};${FFMPEG_AVFORMAT_XCFRAMEWORK};${FFMPEG_AVCODEC_XCFRAMEWORK};${FFMPEG_SWSCALE_XCFRAMEWORK};${FFMPEG_AVUTIL_XCFRAMEWORK};${FFMPEG_AVFILTER_XCFRAMEWORK};${FFMPEG_SWRESAMPLE_XCFRAMEWORK}"
    XCODE_EMBED_FRAMEWORKS_CODE_SIGN_ON_COPY ON
)

target_sources(Vion PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/App Icon.icon"
    "${CMAKE_CURRENT_SOURCE_DIR}/LaunchScreen.storyboard"
    "${CMAKE_CURRENT_SOURCE_DIR}/RobotoMono-Regular.ttf"
    "${CMAKE_CURRENT_SOURCE_DIR}/shaders-builtin.zip"
)

set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/App Icon.icon" PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
)

set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/LaunchScreen.storyboard" PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
)

set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/RobotoMono-Regular.ttf" PROPERTIES 
    MACOSX_PACKAGE_LOCATION Resources/fonts
)

set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/shaders-builtin.zip" PROPERTIES 
    MACOSX_PACKAGE_LOCATION Resources/zips
)