# Define variables
FLUTTER_BUILD_DIR=build/windows/x64/runner/Release
DEPENDENCY_FOLDER=dependency

# Default target
build: build-windows copy-dependencies

# Run flutter build
build-windows:
	fvm flutter build windows --dart-define FLAVOR=prod

# Copy all dependencies to build directory if not already present (Windows-compatible)
copy-dependencies:
	@echo Copying files from $(DEPENDENCY_FOLDER) to $(FLUTTER_BUILD_DIR)...
	xcopy /E /I /Y /D "$(DEPENDENCY_FOLDER)\*" "$(FLUTTER_BUILD_DIR)\dependency\" >nul
	@echo Copy complete.

# Clean build artifacts
clean:
	fvm flutter clean
	if exist "$(FLUTTER_BUILD_DIR)" rmdir /S /Q "$(FLUTTER_BUILD_DIR)"

code:
	@echo "Running make code process..."
	fvm dart run build_runner build
	@echo "Make code process complete."

.PHONY: all build copy-dependencies clean code
