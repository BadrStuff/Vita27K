// Vita3K emulator project
// Copyright (C) 2026 Vita3K team
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#include "ios_bridge.h"

#include "app/functions.h"
#include "app/state.h"
#include "compat/functions.h"
#include "config/functions.h"
#include "config/state.h"
#include "ctrl/functions.h"
#include "emuenv/state.h"
#include "interface.h"
#include "io/state.h"
#include "modules/module_parent.h"
#include "packages/functions.h"
#include "packages/license.h"
#include "packages/pkg.h"
#include "packages/sfo.h"
#include "renderer/functions.h"
#include "renderer/shaders.h"
#include "renderer/state.h"
#include "touch/state.h"
#include "util/fs.h"
#include "util/log.h"
#include "archive.h"

#include <algorithm>

#include <boost/algorithm/string/trim.hpp>
#include <boost/range/numeric.hpp>
#include <rif2zrif.h>
#define SDL_MAIN_HANDLED
#include <SDL3/SDL_joystick.h>
#include <SDL3/SDL_main.h>

#include <miniz.h>

EmuEnvState emuenv_state;
int v_joystick_id = -1;
SDL_Joystick *v_joystick = nullptr;

extern "C" void* get_metal_layer_from_view(void* o) { return o; }

bool unzip_file(const char* zipPath, const char* destination) {
    mz_zip_archive zip{};
    
    if (!mz_zip_reader_init_file(&zip, zipPath, 0)) {
        return false;
    }

    const mz_uint fileCount = mz_zip_reader_get_num_files(&zip);

    for (mz_uint i = 0; i < fileCount; ++i) {
        mz_zip_archive_file_stat stat{};

        if (!mz_zip_reader_file_stat(&zip, i, &stat)) {
            continue;
        }

        const std::string name = stat.m_filename;

        if (name.starts_with("__MACOSX/")) {
            continue;
        }

        std::filesystem::path outPath =
            std::filesystem::path(destination) / name;

        // Directory entry
        if (mz_zip_reader_is_file_a_directory(&zip, i)) {
            std::filesystem::create_directories(outPath);
            continue;
        }

        if (std::filesystem::exists(outPath)) {
            continue;
        }

        std::filesystem::create_directories(outPath.parent_path());

        if (!mz_zip_reader_extract_to_file(
                &zip,
                i,
                outPath.string().c_str(),
                0)) {
            mz_zip_reader_end(&zip);
            return false;
        }
    }

    mz_zip_reader_end(&zip);
    return true;
}

void print_about(void) {
    printf("Welcome to Vion, PlayStation Vita on iPad and iPhone\n");

    SDL_SetMainReady();
    SDL_Init(SDL_INIT_AUDIO | SDL_INIT_GAMEPAD);
}

void init_paths(Root &root_paths) {
    auto create_directory_if_not_exist = [](fs::path path) {
        if (!fs::exists(path))
            fs::create_directory(path);
    };

    create_directory_if_not_exist(root_paths.get_cache_path());
    create_directory_if_not_exist(root_paths.get_config_path());
    create_directory_if_not_exist(root_paths.get_log_path());
    create_directory_if_not_exist(root_paths.get_log_path() / "shaderlog");
    create_directory_if_not_exist(root_paths.get_log_path() / "texturelog");
    create_directory_if_not_exist(root_paths.get_patch_path());
    create_directory_if_not_exist(root_paths.get_pref_path());
    create_directory_if_not_exist(root_paths.get_shared_path());
    create_directory_if_not_exist(root_paths.get_static_assets_path());
}

void initialize_folders(std::string document_directory) {
    printf("%s\n", document_directory.c_str());

    fs::path base_path{ document_directory };

    Root root_paths;
    root_paths.set_base_path(base_path);
    root_paths.set_cache_path(base_path / "cache");
    root_paths.set_config_path(base_path / "config");
    root_paths.set_log_path(base_path / "log");
    root_paths.set_patch_path(base_path / "patch");
    root_paths.set_pref_path(base_path / "fs");
    root_paths.set_shared_path(base_path / "shared");
    root_paths.set_static_assets_path(base_path / "static_assets");

    init_paths(root_paths);

    if (logging::init(root_paths, true) > ExitCode::Success)
        printf("logging init failed\n");

    Config config;

    const int argc = 1;
    char argv0[] = "Vion";
    char *argv[] = { argv0 };
    if (auto exit_code = config::init_config(config, argc, argv, root_paths, root_paths.get_pref_path()); exit_code > ExitCode::Success)
        printf("config init failed: %i\n", exit_code);

    if (!app::init(emuenv_state, config, root_paths))
        printf("app init failed\n");

    init_libraries(emuenv_state);

    if (!app::init_apps_list(emuenv_state))
        printf("app init apps list failed\n");

    app::load_users(emuenv_state);

    if (!app::ensure_current_user(emuenv_state))
        printf("app ensure current user failed\n");

    if (!compat::load_from_disk(emuenv_state.compat, std::filesystem::path{ root_paths.get_cache_path().string() }))
        printf("compat load from disk failed\n");

    emuenv_state.vulkan_device_info = std::make_unique<renderer::VulkanDeviceInfo>(renderer::enumerate_vulkan_devices());
}

void initialize_compatibility(std::string document_directory) {
    if (!compat::load_from_disk(emuenv_state.compat, std::filesystem::path{ emuenv_state.cache_path.string() }))
        printf("compat load from disk failed\n");
}

bool install_license(std::string path_or_zrif) {
    fs::path license_path{ path_or_zrif };
    if (fs::exists(license_path); license_path.extension() == ".bin" || license_path.extension() == ".rif")
        return copy_license(emuenv_state, license_path);
    else {
        return create_license(emuenv_state, path_or_zrif);
    }
}

std::string install_firmware(std::string path, FirmwareProgressCallback callback, void *context) {
    return install_pup(emuenv_state.pref_path, fs::path{ path }, [callback, context](uint32_t progress) {
        if (progress < 100)
            callback(progress, context);
    });
}

bool firmware_installed(void) {
    return app::has_firmware_installed(emuenv_state);
}

PackageHeader get_package_header(std::string path, void *context) {
    FILE *file = fopen(path.c_str(), "rb");

    PackageHeader pkg_header;
    fread(&pkg_header, sizeof(PackageHeader), 1, file);
    fclose(file);

    return pkg_header;
}

std::string get_package_title() {
    return emuenv_state.app_info.app_title;
}

void zrif_exists(std::string path, PackageHeader pkg_header, PackageZrifCallback callback, void *context) {
    std::string title_id_str(pkg_header.content_id);
    std::string title_id = title_id_str.substr(7, 9);

    fs::path work_path{ emuenv_state.pref_path / fmt::format("ux0/license/{}/{}.rif", title_id, pkg_header.content_id) };

    if (fs::exists(work_path)) {
        fs::ifstream file(work_path, std::ios::in | std::ios::binary | std::ios::ate);
        std::string zrif = rif2zrif(file);
        file.close();
        callback(path, zrif, true, context);
    } else {
        callback(path, "", false, context);
    }
}

void install_package_with_zrif(std::string path, std::string zrif, PackageProgressCallback callback, void *context) {
    bool result = install_pkg(fs_utils::utf8_to_path(path), emuenv_state, zrif, [callback, context](float progress) {
        if (progress < 100)
            callback(progress, false, context);
    });
    
    callback(100, result, context);
}

void install_archive(std::string path, PackageProgressCallback callback, void* context) {
    void(install_archive(emuenv_state, path, [callback, context](ArchiveContents contents) {
        if (auto progress = contents.progress.value_or(0); progress < 100)
            callback(progress, false, context);
    }));
    
    callback(100, true, context);
}

std::vector<ApplicationEntry> scan_and_get_apps(void) {
    app::scan_apps(emuenv_state);
    auto apps = app::get_apps(emuenv_state);
    std::vector<ApplicationEntry> ret_apps(apps.begin(), apps.end());
    return ret_apps;
}

void delete_app(std::string path) {
    app::delete_app(emuenv_state, path);
}

template <typename T>
auto get_recursive_directory_size(const T &path) {
    const auto &path_list = fs::recursive_directory_iterator(path);
    const auto pred = [](const auto acc, const auto &app) {
        if (fs::is_regular_file(app.path()))
            return acc + fs::file_size(app.path());
        return acc;
    };
    return boost::accumulate(path_list, boost::uintmax_t{}, pred);
}

int64_t app_size(std::string path, std::string title_id) {
    const auto APP_PATH{ emuenv_state.pref_path / "ux0/app" / path };
    boost::uintmax_t app_size = 0;
    if (fs::exists(APP_PATH) && !fs::is_empty(APP_PATH)) {
        app_size += get_recursive_directory_size(APP_PATH);
    }
    const auto ADDCONT_PATH{ emuenv_state.pref_path / "ux0/addcont" / title_id };
    if (fs::exists(ADDCONT_PATH) && !fs::is_empty(ADDCONT_PATH)) {
        app_size += get_recursive_directory_size(ADDCONT_PATH);
    }
    return (uint32_t)app_size;
}

void boot_game(std::string title_id, std::string fonts_directory, void *context, uint32_t width, uint32_t height) {
    app::set_app_info(emuenv_state, title_id);
    get_license(emuenv_state, emuenv_state.io.title_id, emuenv_state.io.content_id);
    app::update_last_time_app_used(emuenv_state, title_id);

    app::set_current_config(emuenv_state, title_id);

    renderer::WindowCallbacks callbacks;
    callbacks.get_native_handle = [context]() -> void * {
        return reinterpret_cast<void *>(context);
    };
    callbacks.native_handle = reinterpret_cast<void *>(context);
    callbacks.display_protocol = renderer::DisplayProtocol::MacOS;
    callbacks.get_size = [width, height]() -> renderer::WindowSize {
        return renderer::WindowSize{ static_cast<int>(width), static_cast<int>(height) };
    };
    callbacks.has_surface = [width, height]() -> bool {
        return width > 0 && height > 0;
    };
    callbacks.get_font_dirs = [fonts_directory]() -> std::vector<std::string> {
        std::vector<std::string> font_dirs;
        font_dirs.emplace_back(fonts_directory);
        return font_dirs;
    };

    renderer::init(callbacks, emuenv_state.renderer,
        emuenv_state.backend_renderer, emuenv_state.cfg, emuenv_state.get_root_paths());

    app::apply_renderer_config(emuenv_state);

    app::late_init(emuenv_state);

    int32_t main_module_id = 0;
    if (load_app(main_module_id, emuenv_state) > ExitCode::Success)
        return;

    app::reset_controller_binding(emuenv_state);

    SDL_VirtualJoystickDesc desc;
    SDL_INIT_INTERFACE(&desc);
    desc.type = SDL_JOYSTICK_TYPE_GAMEPAD;
    desc.naxes = SDL_GAMEPAD_AXIS_COUNT;
    desc.nbuttons = SDL_GAMEPAD_BUTTON_COUNT;
    desc.name = "Vita3K Virtual Controller";

    v_joystick_id = SDL_AttachVirtualJoystick(&desc);
    if (v_joystick_id == 0)
        LOG_CRITICAL("Could not create overlay virtual controller: {}", SDL_GetError());
    else {
        v_joystick = SDL_OpenJoystick(v_joystick_id);
        if (!v_joystick)
            LOG_CRITICAL("Could not create virtual joystick: {}", SDL_GetError());
    }
    refresh_controllers(emuenv_state.ctrl, emuenv_state);

    emuenv_state.renderer->set_app(emuenv_state.io.title_id.c_str(), emuenv_state.self_name.c_str());
    if (renderer::get_shaders_cache_hashs(*emuenv_state.renderer)) {
        for (const auto &hash : emuenv_state.renderer->shaders_cache_hashs) {
            emuenv_state.renderer->precompile_shader(hash);
            emuenv_state.renderer->swap_window();
        }
    }

    run_app(emuenv_state, main_module_id);

    renderer::start_render_thread(*emuenv_state.renderer, emuenv_state.display, emuenv_state.gxm, emuenv_state.mem, emuenv_state.cfg);
}

void update_touch_position(float x, float y, bool pressed_left, bool pressed_right) {
    if (pressed_left || pressed_right)
        emuenv_state.touch.renderer_focused = true;
    else
        emuenv_state.touch.renderer_focused = false;

    auto &touch = emuenv_state.touch;
    touch.mouse_x = x;
    touch.mouse_y = y;
    touch.mouse_button_left = pressed_left;
    touch.mouse_button_right = pressed_right;
}

void button_press(int button) {
    SDL_SetJoystickVirtualButton(v_joystick, button, true);
    SDL_UpdateJoysticks();
}

void button_release(int button) {
    SDL_SetJoystickVirtualButton(v_joystick, button, false);
    SDL_UpdateJoysticks();
}

void drag_down(int axis, int16_t value) {
    SDL_SetJoystickVirtualAxis(v_joystick, axis, value);
    SDL_UpdateJoysticks();
}

void drag_up(int axis) {
    SDL_SetJoystickVirtualAxis(v_joystick, axis, 0);
    SDL_UpdateJoysticks();
}
