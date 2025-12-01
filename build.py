#!/usr/bin/env python3
"""
Build script for Universal Chat Box
Creates standalone executables for Windows, macOS, and Linux
"""
import os
import sys
import subprocess
import shutil
from pathlib import Path

def run_command(cmd, description):
    """Run a command and handle errors"""
    print(f"\n{'='*60}")
    print(f"{description}")
    print(f"{'='*60}")
    print(f"Running: {' '.join(cmd)}")
    print()
    
    result = subprocess.run(cmd, capture_output=False)
    if result.returncode != 0:
        print(f"\nERROR: {description} failed!")
        sys.exit(1)
    print(f"\n✓ {description} completed successfully")

def build_frontend():
    """Build the React frontend"""
    frontend_dir = Path(__file__).parent.parent / "chat-frontend"
    
    if not frontend_dir.exists():
        print("ERROR: Frontend directory not found!")
        sys.exit(1)
    
    os.chdir(frontend_dir)
    
    run_command(["npm", "run", "build"], "Building frontend")
    
    dist_dir = frontend_dir / "dist"
    if not dist_dir.exists():
        print("ERROR: Frontend build failed - dist directory not found!")
        sys.exit(1)
    
    return dist_dir

def copy_frontend_to_backend(dist_dir):
    """Copy built frontend to backend static directory"""
    backend_dir = Path(__file__).parent
    static_dir = backend_dir / "static"
    
    if static_dir.exists():
        shutil.rmtree(static_dir)
    
    shutil.copytree(dist_dir, static_dir)
    print(f"\n✓ Frontend copied to {static_dir}")
    
    return static_dir

def create_pyinstaller_spec():
    """Create PyInstaller spec file"""
    spec_content = """# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['launcher.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('static', 'static'),
        ('app', 'app'),
    ],
    hiddenimports=[
        'uvicorn.logging',
        'uvicorn.loops',
        'uvicorn.loops.auto',
        'uvicorn.protocols',
        'uvicorn.protocols.http',
        'uvicorn.protocols.http.auto',
        'uvicorn.protocols.websockets',
        'uvicorn.protocols.websockets.auto',
        'uvicorn.lifespan',
        'uvicorn.lifespan.on',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='UniversalChatBox',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

if sys.platform == 'darwin':
    app = BUNDLE(
        exe,
        name='UniversalChatBox.app',
        icon=None,
        bundle_identifier='com.ironjackal.universalchatbox',
        info_plist={
            'NSHighResolutionCapable': 'True',
            'LSBackgroundOnly': 'False',
        },
    )
"""
    
    spec_file = Path(__file__).parent / "UniversalChatBox.spec"
    with open(spec_file, 'w') as f:
        f.write(spec_content)
    
    print(f"\n✓ PyInstaller spec created: {spec_file}")
    return spec_file

def build_executable(spec_file):
    """Build the executable using PyInstaller"""
    backend_dir = Path(__file__).parent
    os.chdir(backend_dir)
    
    run_command(
        ["poetry", "run", "pyinstaller", "--clean", str(spec_file)],
        "Building executable with PyInstaller"
    )
    
    dist_dir = backend_dir / "dist"
    if sys.platform == "darwin":
        exe_path = dist_dir / "UniversalChatBox.app"
    elif sys.platform == "win32":
        exe_path = dist_dir / "UniversalChatBox.exe"
    else:
        exe_path = dist_dir / "UniversalChatBox"
    
    if not exe_path.exists():
        print(f"ERROR: Executable not found at {exe_path}")
        sys.exit(1)
    
    return exe_path

def main():
    print("=" * 60)
    print("UNIVERSAL CHAT BOX - BUILD SCRIPT")
    print("Integrated with IRON JACKAL NEXUS")
    print("=" * 60)
    
    backend_dir = Path(__file__).parent
    os.chdir(backend_dir)
    
    print("\nStep 1: Building frontend...")
    dist_dir = build_frontend()
    
    print("\nStep 2: Copying frontend to backend...")
    copy_frontend_to_backend(dist_dir)
    
    print("\nStep 3: Creating PyInstaller spec...")
    spec_file = create_pyinstaller_spec()
    
    print("\nStep 4: Installing PyInstaller...")
    run_command(
        ["poetry", "add", "pyinstaller"],
        "Installing PyInstaller"
    )
    
    print("\nStep 5: Building executable...")
    exe_path = build_executable(spec_file)
    
    print("\n" + "=" * 60)
    print("BUILD COMPLETE!")
    print("=" * 60)
    print(f"\nExecutable location: {exe_path}")
    print("\nYou can now run the application by double-clicking the executable.")
    print("\nFeatures:")
    print("- 14 AI Shells with unique personalities")
    print("- IRON JACKAL NEXUS integration")
    print("- Peer-to-peer messaging")
    print("- Private and secure (runs on 127.0.0.1)")
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()
