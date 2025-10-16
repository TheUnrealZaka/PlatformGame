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
    if(os.isdir("SDL3") == false) then
        if(not os.isfile("SDL3-devel-VC.zip")) then
            print("SDL3 not found, downloading from GitHub")
            local result_str, response_code = http.download(
                "https://github.com/libsdl-org/SDL/releases/download/release-3.2.22/SDL3-devel-3.2.22-VC.zip", 
                "SDL3-devel-VC.zip", 
                {
                    progress = download_progress,
                    headers = { "From: Premake", "Referer: Premake" }
                }
            )
        end
        print("Unzipping to " .. os.getcwd())
        zip.extract("SDL3-devel-VC.zip", os.getcwd())
        -- Rename the extracted folder to SDL3 for consistency
        if os.isdir("SDL3-3.2.22") then
            os.rename("SDL3-3.2.22", "SDL3")
        end
        os.remove("SDL3-devel-VC.zip")
    end
    os.chdir("../")
end

function check_box2d()
    os.chdir("external")
    if(os.isdir("box2d-2.4.2") == false) then
        if(not os.isfile("box2d-2.4.2.zip")) then
            print("Box2D not found, downloading from github")
            local result_str, response_code = http.download("https://github.com/erincatto/box2d/archive/refs/tags/v2.4.2.zip", "box2d-2.4.2.zip", {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping to " ..  os.getcwd())
        zip.extract("box2d-2.4.2.zip", os.getcwd())
        os.remove("box2d-2.4.2.zip")
    end
    os.chdir("../")
end

function check_libpng()
    os.chdir("external")
    if(os.isdir("libpng-1.6.44") == false) then
        if(not os.isfile("libpng-1.6.44.tar.gz")) then
            print("libpng not found, downloading from official source")
            local result_str, response_code = http.download("https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.44.tar.gz", "libpng-1.6.44.tar.gz", {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Extracting libpng to " .. os.getcwd())
        -- Since this is a .tar.gz, we'll need to extract it using a different method
        os.execute("tar -xzf libpng-1.6.44.tar.gz")
        if os.isdir("libpng-1.6.44") then
            os.rename("libpng-1.6.44", "libpng")
        end
        os.remove("libpng-1.6.44.tar.gz")
    end
    os.chdir("../")
end

function check_libjpeg_turbo()
    os.chdir("external")
    if(os.isdir("libjpeg-turbo-3.0.4") == false) then
        if(not os.isfile("libjpeg-turbo-3.0.4.tar.gz")) then
            print("libjpeg-turbo not found, downloading from github")
            local result_str, response_code = http.download("https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/3.0.4.tar.gz", "libjpeg-turbo-3.0.4.tar.gz", {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Extracting libjpeg-turbo to " .. os.getcwd())
        os.execute("tar -xzf libjpeg-turbo-3.0.4.tar.gz")
        os.remove("libjpeg-turbo-3.0.4.tar.gz")
    end
    os.chdir("../")
end

function check_pugixml()
    os.chdir("external")
    if(os.isdir("pugixml-1.14") == false) then
        if(not os.isfile("pugixml-1.14.zip")) then
            print("pugixml not found, downloading from github")
            local result_str, response_code = http.download("https://github.com/zeux/pugixml/archive/refs/tags/v1.14.zip", "pugixml-1.14.zip", {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping pugixml to " .. os.getcwd())
        zip.extract("pugixml-1.14.zip", os.getcwd())
        os.remove("pugixml-1.14.zip")
    end
    os.chdir("../")
end

function check_sdl3_image()
    os.chdir("external")
    if(os.isdir("SDL_image-3.0.0") == false) then
        if(not os.isfile("SDL_image-3.0.0.zip")) then
            print("SDL3-image not found, downloading from github")
            local result_str, response_code = http.download("https://github.com/libsdl-org/SDL_image/archive/refs/tags/release-3.0.0.zip", "SDL_image-3.0.0.zip", {
                progress = download_progress,
                headers = { "From: Premake", "Referer: Premake" }
            })
        end
        print("Unzipping SDL3-image to " .. os.getcwd())
        zip.extract("SDL_image-3.0.0.zip", os.getcwd())
        os.remove("SDL_image-3.0.0.zip")
    end
    os.chdir("../")
end

function build_externals()
    print("calling externals")
    check_sdl3()
    check_libpng()
    check_libjpeg_turbo()
    check_pugixml()
    check_sdl3_image()
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
box2d_dir = "external/box2d-2.4.2"

downloadLibPNG = true
libpng_dir = "external/libpng"

downloadLibJPEGTurbo = true
libjpeg_turbo_dir = "external/libjpeg-turbo-3.0.4"

downloadPugiXML = true
pugixml_dir = "external/pugixml-1.14"

downloadSDL3Image = true
sdl3_image_dir = "external/SDL_image-3.0.0"

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

if (downloadSDL3 or downloadBox2D or downloadLibPNG or downloadLibJPEGTurbo or downloadPugiXML or downloadSDL3Image) then
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
        includedirs { libpng_dir }
        includedirs { libjpeg_turbo_dir }
        includedirs { pugixml_dir .. "/src" }
        includedirs { sdl3_image_dir .. "/include" }

        cdialect "C17"
        cppdialect "C++17"
        platform_defines()

        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            links {"SDL3.lib"}
            dependson {"box2d", "libpng", "libjpeg-turbo", "pugixml", "sdl3-image"}
            links {"box2d.lib", "libpng.lib", "jpeg.lib", "pugixml.lib", "SDL3_image.lib"}
            characterset ("Unicode")

        filter "system:windows"
            defines{"_WIN32"}
            links {"winmm", "gdi32", "opengl32"}
            
            -- SDL3 x64 específic
            filter { "system:windows", "platforms:x64" }
                libdirs { sdl3_dir .. "/lib/x64" }
                postbuildcommands {
                    -- Path correcte: des de build/build_files/ cap a build/external/SDL3/lib/x64/
                    "{COPY} \"$(SolutionDir)build\\external\\SDL3\\lib\\x64\\SDL3.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\""
                }
                
            -- SDL3 x86 específic
            filter { "system:windows", "platforms:x86" }
                libdirs { sdl3_dir .. "/lib/x86" }
                postbuildcommands {
                    -- Path correcte: des de build/build_files/ cap a build/external/SDL3/lib/x86/
                    "{COPY} \"$(SolutionDir)build\\external\\SDL3\\lib\\x86\\SDL3.dll\" \"$(SolutionDir)bin\\%{cfg.buildcfg}\\\""
                }

        filter "system:linux"
            links {"pthread", "m", "dl", "rt", "X11"}

        filter{}

    project "box2d"
        kind "StaticLib"
        
        location "build_files/"
        
        language "C++"
        targetdir "../bin/%{cfg.buildcfg}"
        
        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            characterset ("Unicode")
            buildoptions { "/Zc:__cplusplus" }
        filter{}
        
        includedirs {box2d_dir, box2d_dir .. "/include", box2d_dir .. "/src" }
        vpaths
        {
            ["Header Files"] = { box2d_dir .. "/include/**.h", box2d_dir .. "/src/**.h"},
            ["Source Files/*"] = { box2d_dir .. "/src/**.cpp"},
        }
        files {box2d_dir .. "/include/**.h", box2d_dir .. "/src/**.cpp", box2d_dir .. "/src/**.h"}
        
        filter{}

    project "libpng"
        kind "StaticLib"
        
        location "build_files/"
        
        language "C"
        targetdir "../bin/%{cfg.buildcfg}"
        
        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            characterset ("Unicode")
        filter{}
        
        includedirs { libpng_dir }
        defines { "PNG_STATIC" }
        
        files { 
            libpng_dir .. "/png.c",
            libpng_dir .. "/pngerror.c",
            libpng_dir .. "/pngget.c",
            libpng_dir .. "/pngmem.c",
            libpng_dir .. "/pngpread.c",
            libpng_dir .. "/pngread.c",
            libpng_dir .. "/pngrio.c",
            libpng_dir .. "/pngrtran.c",
            libpng_dir .. "/pngrutil.c",
            libpng_dir .. "/pngset.c",
            libpng_dir .. "/pngtrans.c",
            libpng_dir .. "/pngwio.c",
            libpng_dir .. "/pngwrite.c",
            libpng_dir .. "/pngwtran.c",
            libpng_dir .. "/pngwutil.c",
            libpng_dir .. "/png.h",
            libpng_dir .. "/pngconf.h"
        }
        
        filter{}

    project "libjpeg-turbo"
        kind "StaticLib"
        
        location "build_files/"
        
        language "C"
        targetdir "../bin/%{cfg.buildcfg}"
        
        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            characterset ("Unicode")
        filter{}
        
        includedirs { libjpeg_turbo_dir }
        
        files { 
            libjpeg_turbo_dir .. "/jaricom.c",
            libjpeg_turbo_dir .. "/jcapimin.c",
            libjpeg_turbo_dir .. "/jcapistd.c",
            libjpeg_turbo_dir .. "/jcarith.c",
            libjpeg_turbo_dir .. "/jccoefct.c",
            libjpeg_turbo_dir .. "/jccolor.c",
            libjpeg_turbo_dir .. "/jcdctmgr.c",
            libjpeg_turbo_dir .. "/jchuff.c",
            libjpeg_turbo_dir .. "/jcinit.c",
            libjpeg_turbo_dir .. "/jcmainct.c",
            libjpeg_turbo_dir .. "/jcmarker.c",
            libjpeg_turbo_dir .. "/jcmaster.c",
            libjpeg_turbo_dir .. "/jcomapi.c",
            libjpeg_turbo_dir .. "/jcparam.c",
            libjpeg_turbo_dir .. "/jcprepct.c",
            libjpeg_turbo_dir .. "/jcsample.c",
            libjpeg_turbo_dir .. "/jctrans.c",
            libjpeg_turbo_dir .. "/jdapimin.c",
            libjpeg_turbo_dir .. "/jdapistd.c",
            libjpeg_turbo_dir .. "/jdarith.c",
            libjpeg_turbo_dir .. "/jdatadst.c",
            libjpeg_turbo_dir .. "/jdatasrc.c",
            libjpeg_turbo_dir .. "/jdcoefct.c",
            libjpeg_turbo_dir .. "/jdcolor.c",
            libjpeg_turbo_dir .. "/jddctmgr.c",
            libjpeg_turbo_dir .. "/jdhuff.c",
            libjpeg_turbo_dir .. "/jdinput.c",
            libjpeg_turbo_dir .. "/jdmainct.c",
            libjpeg_turbo_dir .. "/jdmarker.c",
            libjpeg_turbo_dir .. "/jdmaster.c",
            libjpeg_turbo_dir .. "/jdmerge.c",
            libjpeg_turbo_dir .. "/jdpostct.c",
            libjpeg_turbo_dir .. "/jdsample.c",
            libjpeg_turbo_dir .. "/jdtrans.c",
            libjpeg_turbo_dir .. "/jerror.c",
            libjpeg_turbo_dir .. "/jfdctflt.c",
            libjpeg_turbo_dir .. "/jfdctfst.c",
            libjpeg_turbo_dir .. "/jfdctint.c",
            libjpeg_turbo_dir .. "/jidctflt.c",
            libjpeg_turbo_dir .. "/jidctfst.c",
            libjpeg_turbo_dir .. "/jidctint.c",
            libjpeg_turbo_dir .. "/jmemmgr.c",
            libjpeg_turbo_dir .. "/jmemnobs.c",
            libjpeg_turbo_dir .. "/jquant1.c",
            libjpeg_turbo_dir .. "/jquant2.c",
            libjpeg_turbo_dir .. "/jutils.c",
            libjpeg_turbo_dir .. "/*.h"
        }
        
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

    project "sdl3-image"
        kind "StaticLib"
        
        location "build_files/"
        
        language "C"
        targetdir "../bin/%{cfg.buildcfg}"
        
        filter "action:vs*"
            defines{"_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS"}
            characterset ("Unicode")
        filter{}
        
        includedirs { sdl3_image_dir .. "/include", sdl3_dir .. "/include", libpng_dir, libjpeg_turbo_dir }
        defines { "LOAD_PNG", "LOAD_JPG" }
        
        files { 
            sdl3_image_dir .. "/src/IMG.c",
            sdl3_image_dir .. "/src/IMG_png.c",
            sdl3_image_dir .. "/src/IMG_jpg.c",
            sdl3_image_dir .. "/include/**.h"
        }
        
        dependson { "libpng", "libjpeg-turbo" }
        
        filter{}
