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

#include <bit>
#include <functional>
#include <print>
#include <string.h>

#include "app/state.h"
#include "emuenv/state.h"
#include "packages/sfo.h"

extern "C" {
struct PackageHeader {
    uint32_t magic;
    uint16_t revision;
    uint16_t type;
    uint32_t info_offset;
    uint32_t info_count;
    uint32_t header_size;
    uint32_t file_count;
    uint64_t total_size;
    uint64_t data_offset;
    uint64_t data_size;
    char content_id[0x30];
    uint8_t digest[0x10];
    uint8_t pkg_data_iv[0x10];
    uint8_t pkg_signatures[0x40];
};

struct SfoApplicationInfo {
    std::string app_version;
    std::string app_category;
    std::string app_content_id;
    std::string app_addcont;
    std::string app_savedata;
    std::string app_parental_level;
    std::string app_short_title;
    std::string app_title;
    std::string app_title_id;

    SfoApplicationInfo(const sfo::SfoAppInfo &o) {
        app_version = o.app_version;
        app_category = o.app_category;
        app_content_id = o.app_content_id;
        app_addcont = o.app_addcont;
        app_savedata = o.app_savedata;
        app_parental_level = o.app_parental_level;
        app_short_title = o.app_short_title;
        app_title = o.app_title;
        app_title_id = o.app_title_id;
    }
};

struct ApplicationEntry {
    std::string app_ver;
    std::string category;
    std::string content_id;
    std::string addcont;
    std::string savedata;
    std::string parental_level;
    std::string stitle;
    std::string title;
    std::string title_id;
    std::string path;
    std::string icon_path;

    ApplicationEntry(const app::AppEntry &o) {
        app_ver = o.app_ver;
        category = o.category;
        content_id = o.content_id;
        addcont = o.addcont;
        savedata = o.savedata;
        parental_level = o.parental_level;
        stitle = o.stitle;
        title = o.title;
        title_id = o.title_id;
        path = o.path;
        icon_path = o.icon_path;
    }
};

bool unzip_file(const char*, const char*);

void print_about(void);

void initialize_folders(std::string);
void initialize_compatibility(std::string);

bool install_license(std::string);

using FirmwareProgressCallback = void (*)(uint32_t /* progress */, void * /* context */);
std::string install_firmware(std::string, FirmwareProgressCallback, void *);
bool firmware_installed(void);

using PackageProgressCallback = void (*)(float, bool, void *);
using PackageZrifCallback = void (*)(std::string, std::string, bool, void *);
PackageHeader get_package_header(std::string, void *);
std::string get_package_title(void);
void zrif_exists(std::string, PackageHeader, PackageZrifCallback, void *);
void install_package_with_zrif(std::string, std::string, PackageProgressCallback, void *);

void install_archive(std::string, PackageProgressCallback, void*);

std::vector<ApplicationEntry> scan_and_get_apps(void);
void delete_app(std::string);
int64_t app_size(std::string, std::string);

void boot_game(std::string, std::string, void *, uint32_t, uint32_t);

void update_touch_position(float, float, bool, bool);

void button_press(int);
void button_release(int);

void drag_down(int, int16_t);
void drag_up(int);
}
