#!/usr/bin/env python3
"""
MIRROR WORLDS WRANGLER
Automated deployment and management agent
By: Tiberius (Iron Jackal, Lord of Nuance)
For: Anthony Eric Chavez - The Keeper
"""

import subprocess
import sys
import os
import time
import json
from pathlib import Path

class MirrorWorldsWrangler:
    """Automated wrangler for Mirror Worlds deployment"""
    
    def __init__(self):
        self.base_dir = Path(__file__).parent
        self.api_file = self.base_dir / "mirror_worlds_api.py"
        self.platform_file = self.base_dir / "mirror_worlds_platform.py"
        self.web_file = self.base_dir / "mirror_worlds_web.html"
        self.db_file = self.base_dir / "mirror_worlds.db"
        self.story_dir = self.base_dir / "mirror_worlds_stories"
        self.port = 5000
        
    def check_dependencies(self):
        """Check if all dependencies are installed"""
        print("🔍 Checking dependencies...")
        
        try:
            import flask
            import flask_cors
            print("   ✅ Flask: Installed")
            print("   ✅ Flask-CORS: Installed")
            return True
        except ImportError as e:
            print(f"   ❌ Missing: {e}")
            print("   Installing dependencies...")
            subprocess.run([sys.executable, "-m", "pip", "install", "flask", "flask-cors", "--quiet"])
            print("   ✅ Dependencies installed")
            return True
    
    def initialize_database(self):
        """Initialize the Mirror Worlds database"""
        print("📊 Initializing database...")
        
        try:
            from mirror_worlds_platform import MirrorWorldsPlatform
            platform = MirrorWorldsPlatform()
            print("   ✅ Database initialized")
            return True
        except Exception as e:
            print(f"   ❌ Error: {e}")
            return False
    
    def register_stories(self):
        """Register all story files"""
        print("📚 Registering stories...")
        
        if not self.story_dir.exists():
            print("   ⚠️  Story directory not found")
            return True
        
        try:
            from mirror_worlds_platform import MirrorWorldsPlatform
            platform = MirrorWorldsPlatform()
            
            story_count = 0
            for story_file in self.story_dir.glob("*.json"):
                # Skip non-story files
                if story_file.name.startswith("crossstory") or story_file.name.startswith("token"):
                    continue
                
                try:
                    with open(story_file, 'r') as f:
                        story_data = json.load(f)
                    
                    # Check if it's a valid story (has 'chapters' or 'title')
                    if 'chapters' not in story_data and 'title' not in story_data:
                        continue
                    
                    story_id = platform.register_story(story_data)
                    story_count += 1
                    print(f"   ✅ Registered: {story_data.get('title', story_file.name)}")
                except Exception as e:
                    print(f"   ⚠️  Failed to register {story_file.name}: {e}")
            
            print(f"   ✅ {story_count} stories registered")
            return True
        except Exception as e:
            print(f"   ❌ Error: {e}")
            return False
    
    def check_port(self):
        """Check if port is available"""
        print(f"🔌 Checking port {self.port}...")
        
        try:
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            result = sock.connect_ex(('localhost', self.port))
            sock.close()
            
            if result == 0:
                print(f"   ⚠️  Port {self.port} is in use")
                self.port = 5001
                print(f"   ✅ Will use port {self.port} instead")
            else:
                print(f"   ✅ Port {self.port} is available")
            return True
        except Exception as e:
            print(f"   ⚠️  Could not check port: {e}")
            return True
    
    def start_api(self, background=False):
        """Start the Mirror Worlds API"""
        print("🚀 Starting Mirror Worlds API...")
        
        if not self.api_file.exists():
            print(f"   ❌ API file not found: {self.api_file}")
            return False
        
        # Set environment variables
        env = os.environ.copy()
        env['FLASK_APP'] = str(self.api_file)
        env['FLASK_ENV'] = 'development'
        
        if background:
            print(f"   Starting in background on port {self.port}...")
            process = subprocess.Popen(
                [sys.executable, str(self.api_file)],
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            time.sleep(2)  # Give it time to start
            
            if process.poll() is None:
                print(f"   ✅ API started (PID: {process.pid})")
                print(f"   API: http://localhost:{self.port}")
                return process
            else:
                print("   ❌ API failed to start")
                return None
        else:
            print(f"   Starting on port {self.port}...")
            print(f"   API: http://localhost:{self.port}")
            print("   Press Ctrl+C to stop")
            print("")
            subprocess.run([sys.executable, str(self.api_file)], env=env)
            return True
    
    def setup(self):
        """Complete setup process"""
        print("══════════════════════════════════════════════════════════════")
        print("MIRROR WORLDS WRANGLER - Setup")
        print("══════════════════════════════════════════════════════════════")
        print("")
        
        # Check dependencies
        if not self.check_dependencies():
            return False
        
        # Initialize database
        if not self.initialize_database():
            return False
        
        # Register stories
        if not self.register_stories():
            return False
        
        # Check port
        self.check_port()
        
        print("")
        print("══════════════════════════════════════════════════════════════")
        print("SETUP COMPLETE")
        print("══════════════════════════════════════════════════════════════")
        print("")
        print("✅ All systems ready")
        print("")
        print("🚀 To launch:")
        print("   python3 MIRROR_WORLDS_WRANGLER.py --start")
        print("   or")
        print("   ./LAUNCH_MIRROR_WORLDS.sh")
        print("")
        
        return True
    
    def run(self):
        """Run the wrangler"""
        import argparse
        
        parser = argparse.ArgumentParser(description='Mirror Worlds Wrangler')
        parser.add_argument('--setup', action='store_true', help='Run setup')
        parser.add_argument('--start', action='store_true', help='Start API')
        parser.add_argument('--background', action='store_true', help='Start in background')
        parser.add_argument('--port', type=int, default=5000, help='Port number')
        
        args = parser.parse_args()
        
        self.port = args.port
        
        if args.setup or (not args.start and not args.setup):
            self.setup()
        
        if args.start:
            if not self.setup():
                return
            self.start_api(background=args.background)

if __name__ == '__main__':
    wrangler = MirrorWorldsWrangler()
    wrangler.run()

