# HOL - SDL3 Quickstart Template

A cross-platform C application template using SDL3 with automatic dependency management and build configuration.

## Features

- **SDL3 Integration**: Latest SDL3 with automatic download and setup
- **Cross-platform**: Support for Windows (Visual Studio) and Linux (GCC)
- **Multiple Backends**: OpenGL, Vulkan, Direct3D 11/12 support
- **Automatic Dependency Management**: Downloads and configures SDL3 automatically
- **Multi-architecture**: x64 and x86 platform support

## Project Structure

```
HOL/
├── src/                    # Source code directory
├── include/               # Header files directory
├── build/                 # Build system and dependencies
│   ├── premake5.exe      # Build tool (Windows)
│   ├── premake5.lua      # Build configuration
│   ├── build_files/      # Generated project files
│   └── external/         # External dependencies (auto-downloaded)
│       └── SDL3/         # SDL3 library (auto-managed)
├── bin/                  # Compiled executables
│   ├── Debug/
│   └── Release/
└── README.md
```

## Prerequisites

### Windows
- **Visual Studio 2022** (Community, Professional, or Enterprise)
- **Windows SDK** (latest)
- **Internet connection** (for SDL3 download)

### Linux
- **GCC** with C17 support
- **Development libraries**: X11, OpenGL
- **Internet connection** (for SDL3 download)

## Quick Start

### Windows (Visual Studio)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/HOL.git
   cd HOL
   ```

2. **Execute the batch file to generate the .sln:**
   ```bash
   .\build-VisualStudio2022.bat
   ```
    It will automatically download SDL3 and generate the Visual Studio solution file and open it.    

## SDL Backend Configuration

Choose your preferred graphics backend:

```bash
# OpenGL (default/recommended)
premake5 vs2022 --sdl_backend=opengl

# Vulkan
premake5 vs2022 --sdl_backend=vulkan

# Direct3D 11 (Windows only)
premake5 vs2022 --sdl_backend=d3d11

# Direct3D 12 (Windows only)
premake5 vs2022 --sdl_backend=d3d12

# Auto-detect best backend
premake5 vs2022 --sdl_backend=auto
```

## Platform and Architecture Options

### Platforms
- **x64**: 64-bit (default)
- **x86**: 32-bit

### Build Configurations
- **Debug**: Development build with symbols and assertions
- **Release**: Optimized production build

### Platform-specific Setup

#### Windows
The build system automatically:
- Links SDL3.lib
- Copies SDL3.dll to output directory
- Sets up Windows-specific libraries (winmm, gdi32, opengl32)
- Configures Unicode character set

## Development Workflow

### Adding Source Files
1. Add `.c` files to [`src/`](src/) directory
2. Add `.h` files to [`include/`](include/) directory
3. Rebuild project - files are automatically detected

### Project Structure for Development
```
src/
├── main.c              # Entry point
├── graphics/           # Graphics-related code
├── input/              # Input handling
├── audio/              # Audio processing
└── utils/              # Utility functions

include/
├── graphics.h
├── input.h
├── audio.h
└── utils.h
```

## SDL3 Features Available

This template provides access to all SDL3 capabilities:

- **Graphics**: 2D/3D rendering, multiple backend support
- **Input**: Keyboard, mouse, gamepad, touch
- **Audio**: Playback, recording, spatial audio
- **Window Management**: Multiple windows, fullscreen, borderless
- **File I/O**: Cross-platform file operations
- **Threading**: Thread creation and synchronization
- **Networking**: TCP/UDP sockets
- **Haptic Feedback**: Force feedback devices

## Example Usage

Basic SDL3 application structure:

```c
#include <SDL3/SDL.h>

int main(int argc, char* argv[]) {
    // Initialize SDL3
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("Failed to initialize SDL: %s", SDL_GetError());
        return 1;
    }

    // Create window
    SDL_Window* window = SDL_CreateWindow("HOL - SDL3 App", 
                                         800, 600, 
                                         SDL_WINDOW_RESIZABLE);
    if (!window) {
        SDL_Log("Failed to create window: %s", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    // Main loop
    bool running = true;
    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT) {
                running = false;
            }
        }
        
        // Your rendering code here
        SDL_Delay(16); // ~60 FPS
    }

    // Cleanup
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
```

## Troubleshooting

### SDL3 Download Issues
- **Network problems**: Check internet connection and firewall
- **Manual download**: Download SDL3-devel-3.2.16-VC.zip from [SDL3 releases](https://github.com/libsdl-org/SDL/releases)
- **Extract manually**: Place in `build/external/SDL3/`

### Build Issues
#### Windows
- Ensure Visual Studio 2022 is installed
- Check Windows SDK version
- Run Visual Studio as Administrator if needed

### Runtime Issues
- **Missing SDL3.dll**: Build system should copy automatically
- **Manual fix**: Copy from `build/external/SDL3/lib/x64/SDL3.dll` to `bin/Debug/`

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Resources

- **SDL3 Documentation**: [SDL3 Wiki](https://wiki.libsdl.org/SDL3)
- **SDL3 Source**: [GitHub Repository](https://github.com/libsdl-org/SDL)
- **Premake Documentation**: [Premake5 Docs](https://premake.github.io/docs/)
- **Community**: [SDL Discord](https://discord.com/invite/BwpFGBWsv8)

## Acknowledgments

- [SDL3](https://github.com/libsdl-org/SDL) - Simple DirectMedia Layer
- [Premake5](https://premake.github.io/) - Build configuration tool