newoption
{
    trigger = "sdl_backend",
    value = "BACKEND",
    description = "SDL backend to use",
    allowed = {
        { "auto", "Auto-detect best backend" },
        { "opengl", "OpenGL backend" },
        { "vulkan", "Vulkan backend" },
        { "d3d11", "Direct3D 11 backend" },
        { "d3d12", "Direct3D 12 backend" }
    },
    default = "auto"
}

function download_progress(total, current)
    local ratio = current / total
    ratio = math.min(math.max(ratio, 0), 1)
    local percent = math.floor(ratio * 100)
    print("Download progress (" .. percent .. "%/100%)")
end

function check_sdl3()
    os.chdir("external")
    
    -- Get the cached versions (will fetch only once)
    local versions = get_latest_versions()
    local sdl3_version = versions.sdl3
    local sdl3_folder = "SDL3-" .. sdl3_version
    local sdl3_zip = "SDL3-devel-" .. sdl3_version .. "-VC.zip"
    
    if(os.isdir("SDL3") == false) then
        if(not os.isfile(sdl3_zip)) then
            print("SDL3 v" .. sdl3_version .. " not found, downloading from GitHub")
            local download_url = "https://github.com/libsdl-org/SDL/releases/download/release-" .. sdl3_version .. "/SDL3-devel-" .. sdl3_version .. "-VC.zip"
            local result_str, response_code = http.download(download_url, sdl3_zip, {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping SDL3 to " .. os.getcwd())
        zip.extract(sdl3_zip, os.getcwd())
        
        -- Rename the extracted folder to simple name
        if os.isdir(sdl3_folder) then
            os.rename(sdl3_folder, "SDL3")
            print("Renamed " .. sdl3_folder .. " to SDL3")
        end
        
        os.remove(sdl3_zip)
    else
        print("SDL3 already exists")
    end
    
    os.chdir("../")
end

-- Global variable to cache versions
local cached_versions = nil

function get_latest_versions()
    -- Return cached versions if already fetched
    if cached_versions then
        return cached_versions
    end
    
    -- Define repositories and their fallback versions
    local repos = {
        sdl3 = {
            repo = "libsdl-org/SDL",
            fallback = "3.2.22"
        },
        box2d = {
            repo = "erincatto/box2d",
            fallback = "3.1.1"
        },
        libpng = {
            repo = "pnggroup/libpng",
            fallback = "1.6.44"
        },
        libjpeg_turbo = {
            repo = "libjpeg-turbo/libjpeg-turbo",
            fallback = "3.0.4"
        },
        pugixml = {
            repo = "zeux/pugixml",
            fallback = "1.14"
        },
        sdl3_image = {
            repo = "libsdl-org/SDL_image",
            fallback = "3.0.0"
        }
    }
    
    local versions = {}
    
    print("Fetching latest versions for all externals...")
    
    for name, info in pairs(repos) do
        print("Checking latest " .. name .. " version...")
        local result_str, response_code = http.get("https://api.github.com/repos/" .. info.repo .. "/releases/latest")
        
        if response_code == 200 and result_str then
            -- Parse JSON to extract tag_name, handle both "v1.2.3" and "release-1.2.3" formats
            local tag_match = string.match(result_str, '"tag_name"%s*:%s*"[vr]?[elase]*%-?([^"]+)"')
            if tag_match then
                versions[name] = tag_match
                print("Latest " .. name .. " version found: " .. tag_match)
            else
                versions[name] = info.fallback
                print("Could not parse " .. name .. " version from API response, using fallback: " .. info.fallback)
            end
        else
            versions[name] = info.fallback
            print("Could not fetch latest " .. name .. " version from GitHub API (response code: " .. tostring(response_code) .. "), using fallback: " .. info.fallback)
        end
        
        -- Add a small delay between API calls to avoid rate limiting
        if next(repos, name) then  -- Not the last iteration
            print("Waiting briefly to avoid rate limiting...")
            os.execute("ping 127.0.0.1 -n 2 > nul")  -- 1 second delay on Windows
        end
    end
    
    -- Cache the results
    cached_versions = versions
    return versions
end

function check_box2d()
    os.chdir("external")
    
    -- Get the cached versions (will fetch only once)
    local versions = get_latest_versions()
    local box2d_version = versions.box2d
    local box2d_folder = "box2d-" .. box2d_version
    local box2d_zip = box2d_folder .. ".zip"
    
    if(os.isdir("box2d") == false) then
        if(not os.isfile(box2d_zip)) then
            print("Box2D v" .. box2d_version .. " not found, downloading from github")
            local download_url = "https://github.com/erincatto/box2d/archive/refs/tags/v" .. box2d_version .. ".zip"
            local result_str, response_code = http.download(download_url, box2d_zip, {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping to " .. os.getcwd())
        zip.extract(box2d_zip, os.getcwd())
        
        -- Rename the extracted folder to simple name
        if os.isdir(box2d_folder) then
            os.rename(box2d_folder, "box2d")
            print("Renamed " .. box2d_folder .. " to box2d")
        end
        
        os.remove(box2d_zip)
    else
        print("Box2D already exists")
    end
    
    os.chdir("../")
end

function check_libjpeg_turbo()
    os.chdir("external")
    
    -- Use fixed version for prebuilt binaries
    local libjpeg_version = "3.1.2"
    local libjpeg_exe = "libjpeg-turbo-" .. libjpeg_version .. "-vc-x64.exe"
    
    if(os.isdir("libjpeg-turbo") == false) then
        if(not os.isfile(libjpeg_exe)) then
            print("libjpeg-turbo v" .. libjpeg_version .. " not found, downloading prebuilt binaries from GitHub")
            local download_url = "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/" .. libjpeg_version .. "/libjpeg-turbo-" .. libjpeg_version .. "-vc-x64.exe"
            local result_str, response_code = http.download(download_url, libjpeg_exe, {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        
        print("Extracting libjpeg-turbo using 7zip...")
        -- Create temp directory for extraction
        os.mkdir("libjpeg-turbo-temp")
        
        -- Extract the .exe using 7zip (NSIS installer)
        local extract_cmd = "7z x \"" .. libjpeg_exe .. "\" -o\"libjpeg-turbo-temp\" -y"
        local result = os.execute(extract_cmd)
        
        if result == 0 then
            -- Create final directory structure
            os.mkdir("libjpeg-turbo")
            os.mkdir("libjpeg-turbo/include")
            os.mkdir("libjpeg-turbo/lib")
            os.mkdir("libjpeg-turbo/bin")
            
            -- Copy include files
            if os.isdir("libjpeg-turbo-temp/include") then
                os.execute("xcopy /E /I /Y libjpeg-turbo-temp\\include libjpeg-turbo\\include")
            end
            
            -- Copy lib files
            if os.isdir("libjpeg-turbo-temp/lib") then
                os.execute("xcopy /E /I /Y libjpeg-turbo-temp\\lib libjpeg-turbo\\lib")
            end
            
            -- Copy bin files (DLLs)
            if os.isdir("libjpeg-turbo-temp/bin") then
                os.execute("xcopy /E /I /Y libjpeg-turbo-temp\\bin libjpeg-turbo\\bin")
            end
            
            -- Clean up temp directory
            os.execute("rmdir /S /Q libjpeg-turbo-temp")
            os.remove(libjpeg_exe)
            
            print("libjpeg-turbo extracted successfully")
        else
            print("ERROR: Failed to extract libjpeg-turbo. Make sure 7zip is installed and in PATH.")
        end
    else
        print("libjpeg-turbo already exists")
    end
    
    os.chdir("../")
end

function check_pugixml()
    os.chdir("external")
    
    -- Get the cached versions (will fetch only once)
    local versions = get_latest_versions()
    local pugixml_version = versions.pugixml
    local pugixml_folder = "pugixml-" .. pugixml_version
    local pugixml_zip = pugixml_folder .. ".zip"
    
    if(os.isdir("pugixml") == false) then
        if(not os.isfile(pugixml_zip)) then
            print("pugixml v" .. pugixml_version .. " not found, downloading from github")
            local download_url = "https://github.com/zeux/pugixml/archive/refs/tags/v" .. pugixml_version .. ".zip"
            local result_str, response_code = http.download(download_url, pugixml_zip, {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping pugixml to " .. os.getcwd())
        zip.extract(pugixml_zip, os.getcwd())
        
        -- Rename the extracted folder to simple name
        if os.isdir(pugixml_folder) then
            os.rename(pugixml_folder, "pugixml")
            print("Renamed " .. pugixml_folder .. " to pugixml")
        end
        
        os.remove(pugixml_zip)
    else
        print("pugixml already exists")
    end
    
    os.chdir("../")
end

function check_sdl3_image()
    os.chdir("external")
    
    -- Use a fixed version for the prebuilt binaries
    local sdl3_image_version = "3.2.4"
    local sdl3_image_folder = "SDL3_image-" .. sdl3_image_version
    local sdl3_image_zip = "SDL3_image-devel-" .. sdl3_image_version .. "-VC.zip"
    
    if(os.isdir("SDL3_image") == false) then
        if(not os.isfile(sdl3_image_zip)) then
            print("SDL3_image v" .. sdl3_image_version .. " not found, downloading prebuilt binaries from GitHub")
            local download_url = "https://github.com/libsdl-org/SDL_image/releases/download/release-" .. sdl3_image_version .. "/SDL3_image-devel-" .. sdl3_image_version .. "-VC.zip"
            local result_str, response_code = http.download(download_url, sdl3_image_zip, {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping SDL3_image to " .. os.getcwd())
        zip.extract(sdl3_image_zip, os.getcwd())
        
        -- Rename the extracted folder to simple name
        if os.isdir(sdl3_image_folder) then
            os.rename(sdl3_image_folder, "SDL3_image")
            print("Renamed " .. sdl3_image_folder .. " to SDL3_image")
        end
        
        os.remove(sdl3_image_zip)
    else
        print("SDL3_image already exists")
    end
    
    os.chdir("../")
end

function build_externals()
    print("calling externals")
    check_sdl3()
    check_libjpeg_turbo()
    check_pugixml()
    check_sdl3_image()
    if (downloadBox2D) then
        check_box2d()
    end
end

function platform_defines()
    filter {"configurations:Debug"}
        defines{"DEBUG", "_DEBUG"}
        symbols "On"

    filter {"configurations:Release"}
        defines{"NDEBUG", "RELEASE"}
        optimize "On"

    filter {"system:windows"}
        defines {"_WIN32", "_WINDOWS"}
        systemversion "latest"

    filter {"system:linux"}
        defines {"_GNU_SOURCE"}
        
    filter{}
end

-- Configuration
downloadSDL3 = true
sdl3_dir = "external/SDL3"

downloadBox2D = true
box2d_dir = "external/box2d"

downloadLibJPEGTurbo = true
libjpeg_turbo_dir = "external/libjpeg-turbo"

downloadPugiXML = true
pugixml_dir = "external/pugixml"

downloadSDL3Image = true
sdl3_image_dir = "external/SDL3_image"

workspaceName = 'PlatformGame'
baseName = path.getbasename(path.getdirectory(os.getcwd()))

-- Use parent folder name for workspace
workspaceName = baseName

if (os.isdir('build_files') == false) then
    os.mkdir('build_files')
end

if (os.isdir('external') == false) then
    os.mkdir('external')
end

workspace (workspaceName)
    location "../"
    configurations { "Debug", "Release" }
    platforms { "x64", "x86" }

    defaultplatform ("x64")

    filter "configurations:Debug"
        defines { "DEBUG" }
        symbols "On"

    filter "configurations:Release"
        defines { "NDEBUG" }
        optimize "On"

    filter { "platforms:x64" }
        architecture "x86_64"

    filter { "platforms:x86" }
        architecture "x86"

    filter {}

    targetdir "bin/%{cfg.buildcfg}/"

if (downloadSDL3 or downloadBox2D or downloadLibJPEGTurbo or downloadPugiXML or downloadSDL3Image) then
    build_externals()
end

    startproject(workspaceName)

    project (workspaceName)
        kind "ConsoleApp"
        location "build_files/"
        targetdir "../bin/%{cfg.buildcfg}"

        filter "action:vs*"
            debugdir "$(SolutionDir)"

        filter{}

        vpaths 
        {
            ["Header Files/*"] = { "../include/**.h", "../include/**.hpp", "../src/**.h", "../src/**.hpp"},
            ["Source Files/*"] = {"../src/**.c", "../src/**.cpp"},
        }
        
        files {
            "../src/**.c", 
            "../src/**.cpp", 
            "../src/**.h", 
            "../src/**.hpp", 
            "../include/**.h", 
            "../include/**.hpp"
        }

        includedirs { "../src" }
        includedirs { "../include" }
        includedirs { sdl3_dir .. "/include" }
        includedirs { box2d_dir .. "/include" }
        includedirs { libjpeg_turbo_dir .. "/include" }
        includedirs { pugixml_dir .. "/src" }
        includedirs { sdl3_image_dir .. "/include" }

        cdialect "C17"
        cppdialect "C++17"
        platform_defines()

        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            links {"SDL3.lib"}
            dependson {"box2d", "pugixml"}
            links {"box2d.lib", "SDL3_image.lib", "pugixml.lib", "jpeg.lib"}
            characterset ("Unicode")

        filter "system:windows"
            defines{"_WIN32"}
            links {"winmm", "gdi32", "opengl32"}
            
            -- SDL3 x64 específic
            filter { "system:windows", "platforms:x64" }
                libdirs { sdl3_dir .. "/lib/x64", sdl3_image_dir .. "/lib/x64", libjpeg_turbo_dir .. "/lib" }
                postbuildcommands {
                    -- Path correcte: des de build/build_files/ cap a build/external/SDL3/lib/x64/
                    "{COPY} \"$(SolutionDir)build\\external\\SDL3\\lib\\x64\\SDL3.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\"",
                    "{COPY} \"$(SolutionDir)build\\external\\SDL3_image\\lib\\x64\\SDL3_image.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\"",
                    "{COPY} \"$(SolutionDir)build\\external\\libjpeg-turbo\\bin\\jpeg62.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\""
                }
                
            -- SDL3 x86 específic
            filter { "system:windows", "platforms:x86" }
                libdirs { sdl3_dir .. "/lib/x86", sdl3_image_dir .. "/lib/x86", libjpeg_turbo_dir .. "/lib" }
                postbuildcommands {
                    -- Path correcte: des de build/build_files/ cap a build/external/SDL3/lib/x86/
                    "{COPY} \"$(SolutionDir)build\\external\\SDL3\\lib\\x86\\SDL3.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\"",
                    "{COPY} \"$(SolutionDir)build\\external\\SDL3_image\\lib\\x86\\SDL3_image.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\"",
                    "{COPY} \"$(SolutionDir)build\\external\\libjpeg-turbo\\bin\\jpeg62.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\""
                }

        filter "system:linux"
            links {"pthread", "m", "dl", "rt", "X11"}

        filter{}

    project "box2d"
        kind "StaticLib"
        
        location "build_files/"
        
        language "C"
        targetdir "../bin/%{cfg.buildcfg}"
        
        -- Use C11 standard for static_assert support
        cdialect "C11"
        
        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            characterset ("Unicode")
            -- MSVC compatibility: Force C compilation
            buildoptions { "/TC" }
            -- For MSVC, define _Static_assert as a no-op since MSVC doesn't fully support C11
            defines { "_Static_assert(x,y)=" }
        
        filter "system:not windows"
            -- For non-Windows systems, ensure C11 support and define required macros
            buildoptions { "-std=c11" }
            defines { "_GNU_SOURCE", "_POSIX_C_SOURCE=200809L" }
        
        filter{}
        
        includedirs {box2d_dir, box2d_dir .. "/include", box2d_dir .. "/src", box2d_dir .. "/extern/simde" }
        vpaths
        {
            ["Header Files"] = { box2d_dir .. "/include/**.h", box2d_dir .. "/src/**.h"},
            ["Source Files/*"] = { box2d_dir .. "/src/**.c"},
        }
        files {box2d_dir .. "/include/**.h", box2d_dir .. "/src/**.c", box2d_dir .. "/src/**.h"}
        
        filter{}

    project "pugixml"
        kind "StaticLib"
        
        location "build_files/"
        
        language "C++"
        targetdir "../bin/%{cfg.buildcfg}"
        
        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            characterset ("Unicode")
        filter{}
        
        includedirs { pugixml_dir .. "/src" }
        
        files { 
            pugixml_dir .. "/src/pugixml.cpp",
            pugixml_dir .. "/src/pugixml.hpp",
            pugixml_dir .. "/src/pugiconfig.hpp"
        }
        
        filter{}
