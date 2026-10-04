# Imports
# GUI (Primary And Fallback)
import webview
import customtkinter as ctk
from tkinter import messagebox
# Text Parsing
import json
import re
# Misc
import traceback
import threading
import subprocess
import requests
import io
import base64
import time
import sys
import webbrowser
import os
import shutil
from pathlib import Path
# Computer Vision
from PIL import Image
import numpy as np
# Capture
if sys.platform == "win32":
    try:
        import dxcam
    except:
        dxcam = None
else:
    dxcam = None
try:
    if dxcam is None:
        from fastgrab import screenshot
    else:
        screenshot = None
except ImportError:
    screenshot = None
try:
    img = screenshot.Screenshot().capture()
except:
    screenshot = None
import mss
# Keyboard And Mouse Clicks (Platform-specific)
from pynput.keyboard import Listener as KeyListener, Key
from pynput import keyboard, mouse
from pynput.keyboard import Controller as KeyboardController
from pynput.mouse import Controller as MouseController
from pynput.mouse import Button
if sys.platform == "win32":
    import ctypes
    from ctypes import wintypes
elif sys.platform == "darwin":
    import Quartz
    import AppKit
elif sys.platform == "linux":
    from Xlib import X, XK, display as Xdisplay
    from Xlib.ext import xtest
# OCR (With Fallback If User Didn'T Install Tesseract)
try:
    import pytesseract
    if sys.platform == "win32":
        possible = shutil.which("tesseract")
        if possible:
            pytesseract.pytesseract.tesseract_cmd = possible
    else:
        pytesseract.pytesseract.tesseract_cmd = "/opt/homebrew/bin/tesseract"
except:
    pytesseract = None
# Define Platform-Specific Constants
# All Platforms
keyboard_controller = KeyboardController()
mouse_controller = MouseController()
APP_VERSION = 1.52
BETA_VERSION = 0
DEVELOPER = "Catman2608"
def load_misc_settings(last_config_path):
    try:
        with open(last_config_path, "r", encoding="utf-8") as file:
            data = json.load(file)
        return data
    except:
        return {}
def get_macos_menu_offset():
    if sys.platform != "darwin":
        return 0

    try:
        screen = AppKit.NSScreen.mainScreen()
        full_frame = screen.frame()
        visible_frame = screen.visibleFrame()
        return int(full_frame.size.height - visible_frame.size.height)

    except Exception:
        return 0

if sys.platform == "darwin":
    _QUARTZ_SRGB_COLOR_SPACE = Quartz.CGColorSpaceCreateWithName(
        Quartz.kCGColorSpaceSRGB
    )
else:
    _QUARTZ_SRGB_COLOR_SPACE = None
def cgimage_to_srgb_numpy(image):
    if sys.platform == "darwin":
        width = Quartz.CGImageGetWidth(image)
        height = Quartz.CGImageGetHeight(image)
        bytes_per_row = width * 4
        # Allocate The Destination Buffer Once Per Frame.
        raw = np.empty((height, width, 4), dtype=np.uint8)
        # Reuse The Cached Srgb Color Space.
        context = Quartz.CGBitmapContextCreate(
            raw,
            width,
            height,
            8,
            bytes_per_row,
            _QUARTZ_SRGB_COLOR_SPACE,
            Quartz.kCGImageAlphaPremultipliedLast |
            Quartz.kCGBitmapByteOrder32Big
        )
        if context is None:
            return None

        Quartz.CGContextDrawImage(
            context,
            Quartz.CGRectMake(0, 0, width, height),
            image
        )
        # Return A Bgr View Without Making Another Fullframe Allocation.
        return raw[:, :, :3][:, :, ::-1]

    return image

# Screen Dimensions Via MSS — Use Monitor[1] (Primary) Not Monitor[0] (Virtual Combined).
# On Windows With Dpi Scaling, Pywebview'S X/Y/Width/Height Use Physical Pixels,
# So We Must Query The Raw Physical Resolution, Not The Scaled Logical Resolution.
try:
    MSS = mss.MSS
except AttributeError:
    MSS = mss.mss
with MSS() as _sct:
    if len(_sct.monitors) > 1:
        _m = _sct.monitors[1]   # Primary monitor
    else:
        _m = _sct.monitors[0]   # Fallback: only one entry exists
    SCREEN_WIDTH  = _m["width"]
    SCREEN_HEIGHT = _m["height"]
    SCREEN_LEFT   = _m["left"]
    SCREEN_TOP    = _m["top"]
HALF_WIDTH = int(SCREEN_WIDTH / 2)
HALF_HEIGHT = int(SCREEN_HEIGHT / 2)
# Windows (Transparency And Ctypes Windll)
if sys.platform == "win32":
    windll = ctypes.windll.user32
    MOUSEEVENTF_MOVE = 0x0001
    MOUSEEVENTF_LEFTDOWN = 0x0002
    MOUSEEVENTF_LEFTUP = 0x0004
    MOUSEEVENTF_RIGHTDOWN = 0x0008
    MOUSEEVENTF_RIGHTUP = 0x0010
    # Ctypes GUI Constants
    SW_MAXIMIZE = 3
    user32 = ctypes.windll.user32
    user32.GetWindowLongW.restype = wintypes.LONG
    user32.GetWindowLongW.argtypes = [wintypes.HWND, ctypes.c_int]
    user32.SetWindowLongW.restype = wintypes.LONG
    user32.SetWindowLongW.argtypes = [wintypes.HWND, ctypes.c_int, wintypes.LONG]
    user32.SetLayeredWindowAttributes.restype = wintypes.BOOL
    user32.SetLayeredWindowAttributes.argtypes = [wintypes.HWND, wintypes.COLORREF, ctypes.c_byte, wintypes.DWORD]
    user32.ShowWindow.restype = wintypes.BOOL
    user32.ShowWindow.argtypes = [
        wintypes.HWND,
        ctypes.c_int
    ]
    # Set Dpi Awareness Early To Ensure Consistent Coordinate Handling
    try:
        windll.shcore.SetProcessDpiAwareness(1)  # PROCESS_PER_MONITOR_DPI_AWARE
        # Dpi Awareness Successfully Set
    except:
        try:
            windll.user32.SetProcessDPIAware()  # Fallback for older Windows
            # Dpi Awareness Set (Fallback Method)
        except:
            pass  # DPI awareness could not be set - coordinates may be inconsistent

    # Windows Api Related Functions
    def get_scale_factor():
        return 1

    def _get_hwnd(window):
        """Return a Windows HWND int from a pywebview window/native object."""
        native = getattr(window, "native", window)
        candidates = (
            native,
            getattr(native, "Handle", None),# WinForms BrowserForm -> System.IntPtr
            getattr(window, "Handle", None),
            getattr(window, "hwnd", None),
        )
        for candidate in candidates:
            if not candidate:
                continue

            if isinstance(candidate, int):
                return candidate

            if hasattr(candidate, "value") and candidate.value:
                return int(candidate.value)

            if hasattr(candidate, "ToInt64"):
                value = int(candidate.ToInt64())
                if value:
                    return value

            if hasattr(candidate, "ToInt32"):
                value = int(candidate.ToInt32())
                if value:
                    return value

            try:
                value = int(candidate)
            except (TypeError, ValueError):
                continue

            if value:
                return value

        return None

# macOS (Keyboard, Scale Factor, Mouse Button)
elif sys.platform == "darwin":
    _scale_cache = None
    MAC_KEY_MAP = {
        "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7, "c": 8, "v": 9,
        "b": 11, "q": 12, "w": 13, "e": 14, "r": 15, "y": 16, "t": 17, "1": 18, "2": 19, "3": 20,
        "4": 21, "6": 22, "5": 23, "equal": 24, "9": 25, "7": 26, "minus": 27, "8": 28, "0": 29, "o": 31,
        "u": 32, "i": 34, "p": 35, "l": 37, "j": 38, "k": 40, "semicolon": 41, "comma": 43, "slash": 44, "n": 45,
        "m": 46, "period": 47, "space": 49, "return": 36, "enter": 76, "tab": 48, "escape": 53,
    }
    def get_scale_factor():
        global _scale_cache
        if _scale_cache is not None:
            return _scale_cache

        try:
            _scale_cache = float(AppKit.NSScreen.mainScreen().backingScaleFactor())
        except Exception:
            _scale_cache = 1.0
        return _scale_cache

    def get_mouse_position():
        event = Quartz.CGEventCreate(None)
        loc = Quartz.CGEventGetLocation(event)
        return loc.x, loc.y

    def _move_mouse(x, y):
        """Expects logical points."""
        point = Quartz.CGPointMake(x, y)
        Quartz.CGWarpMouseCursorPosition(point)
        Quartz.CGAssociateMouseAndMouseCursorPosition(True)
    def _mouse_event(button="left", press=True, x=None, y=None):
        """Unified cross-platform mouse event.
        button: 'left'/'right'/'middle' or 1/2/3
        press=True → down, False → up
        """
        if x is None or y is None:
            x, y = get_mouse_position()
        # Map Button → (Quartz Button Constant, Down Event, Up Event)
        button_map = {
            "left":   (Quartz.kCGMouseButtonLeft, Quartz.kCGEventLeftMouseDown, Quartz.kCGEventLeftMouseUp),
            1:        (Quartz.kCGMouseButtonLeft, Quartz.kCGEventLeftMouseDown, Quartz.kCGEventLeftMouseUp),
            "right":  (Quartz.kCGMouseButtonRight,Quartz.kCGEventRightMouseDown,Quartz.kCGEventRightMouseUp),
            3:        (Quartz.kCGMouseButtonRight,Quartz.kCGEventRightMouseDown,Quartz.kCGEventRightMouseUp),
            "middle": (Quartz.kCGMouseButtonCenter, Quartz.kCGEventOtherMouseDown,Quartz.kCGEventOtherMouseUp),
            2:        (Quartz.kCGMouseButtonCenter, Quartz.kCGEventOtherMouseDown,Quartz.kCGEventOtherMouseUp),
        }
        key = button.lower() if isinstance(button, str) else button
        if key not in button_map:
            key = "left"
        btn, down_evt, up_evt = button_map[key]
        event_type = down_evt if press else up_evt
        event = Quartz.CGEventCreateMouseEvent(
            None,
            event_type,
            Quartz.CGPointMake(float(x), float(y)),
            btn
        )
        Quartz.CGEventPost(Quartz.kCGHIDEventTap, event)
    def send_key(key, delay=0.05, click_type=0):
        """
        Send a keyboard event.
        click_type:
            0 = click (press + release)   [default]
            1 = hold (press only)
            2 = release (release only)
        """
        keycode = MAC_KEY_MAP.get(str(key).lower())
        if keycode is None:
            return

        if click_type == 0:           # Click (press + release)
            Quartz.CGEventPost(
                Quartz.kCGHIDEventTap,
                Quartz.CGEventCreateKeyboardEvent(None, keycode, True)   # key down
            )
            time.sleep(delay)
            Quartz.CGEventPost(
                Quartz.kCGHIDEventTap,
                Quartz.CGEventCreateKeyboardEvent(None, keycode, False)  # key up
            )
        elif click_type == 1:         # Hold (press only)
            Quartz.CGEventPost(
                Quartz.kCGHIDEventTap,
                Quartz.CGEventCreateKeyboardEvent(None, keycode, True)   # key down
            )
        elif click_type == 2:         # Release only
            Quartz.CGEventPost(
                Quartz.kCGHIDEventTap,
                Quartz.CGEventCreateKeyboardEvent(None, keycode, False)  # key up
            )
        else:
            # Fallback To Normal Click If Invalid Value Is Passed
            Quartz.CGEventPost(
                Quartz.kCGHIDEventTap,
                Quartz.CGEventCreateKeyboardEvent(None, keycode, True)
            )
            time.sleep(delay)
            Quartz.CGEventPost(
                Quartz.kCGHIDEventTap,
                Quartz.CGEventCreateKeyboardEvent(None, keycode, False)
            )
# Linux (Mouse Positions And Xdisplay)
elif sys.platform.startswith("linux"):
    _xdisplay = None
    def _get_xdisplay():
        global _xdisplay
        if _xdisplay is None:
            _xdisplay = Xdisplay.Display()
        return _xdisplay

    def get_scale_factor():
        """
        X11 normally works in physical pixels.
        Return 1.0 unless you implement desktop-specific scaling detection.
        """
        return 1.0

    def get_mouse_position():
        d = _get_xdisplay()
        root = d.screen().root
        pointer = root.query_pointer()
        return pointer.root_x, pointer.root_y

    def _move_mouse(x, y):
        d = _get_xdisplay()
        root = d.screen().root
        root.warp_pointer(int(x), int(y))
        d.sync()
    def _mouse_event(button="left", press=True, x=None, y=None):
        """Unified cross-platform mouse event.
        button: 'left'/'right'/'middle' or 1/2/3
        press=True → down, False → up
        """
        d = _get_xdisplay()
        if x is not None and y is not None:
            _move_mouse(x, y)   # move first so the click happens at the desired location
        button_map = {
            "left": 1, 1: 1,
            "middle": 2, 2: 2,
            "right": 3, 3: 3,
        }
        key = button.lower() if isinstance(button, str) else button
        btn = button_map.get(key, 1)
        xtest.fake_input(
            d,
            X.ButtonPress if press else X.ButtonRelease,
            btn
        )
        d.sync()
    def send_key(key, delay=0.05, click_type=0):
        d = _get_xdisplay()
        keysym = XK.string_to_keysym(str(key))
        if keysym == 0:
            keysym = XK.string_to_keysym(str(key).lower())
        if keysym == 0:
            return

        keycode = d.keysym_to_keycode(keysym)
        if keycode == 0:
            return

        if click_type == 0:
            xtest.fake_input(d, X.KeyPress, keycode)
            d.sync()
            time.sleep(delay)
            xtest.fake_input(d, X.KeyRelease, keycode)
            d.sync()
        elif click_type == 1:
            xtest.fake_input(d, X.KeyPress, keycode)
            d.sync()
        elif click_type == 2:
            xtest.fake_input(d, X.KeyRelease, keycode)
            d.sync()
        else:
            xtest.fake_input(d, X.KeyPress, keycode)
            d.sync()
            time.sleep(delay)
            xtest.fake_input(d, X.KeyRelease, keycode)
            d.sync()
# Path Management
def _is_frozen():
    return bool(getattr(sys, "frozen", False))

def get_exe_dir():
    """Directory that contains the running executable (or the .py file in dev)."""
    if _is_frozen():
        return Path(sys.executable).parent.resolve()
    return Path(__file__).parent.resolve()

def get_resource_path():
    """
    Packaged assets (ui/, images/, bundled default configs/).
    Compiled macOS/Linux: PyInstaller onedir --add-data folder (sys._MEIPASS,
    typically <app>/_internal or .app/Contents/Frameworks).
    Compiled Windows: directory next to the .exe (unchanged).
    Dev: project directory.
    """
    if _is_frozen():
        if sys.platform == "win32":
            return Path(sys.executable).parent.resolve()
        if hasattr(sys, "_MEIPASS"):
            return Path(sys._MEIPASS).resolve()
        return Path(sys.executable).parent.resolve()
    return Path(__file__).parent.resolve()

def get_appdata_path():
    """Writable user data. Compiled → platform AppData; dev → project directory."""
    if _is_frozen():
        if sys.platform == "darwin":
            return os.path.join(
                os.path.expanduser("~"),
                "Library", "Application Support",
                "SolarFishingV5"
            )
        elif sys.platform == "win32":
            return os.path.join(
                os.path.expanduser("~"),
                "AppData", "Roaming",
                "SolarFishingV5"
            )
        else:
            return os.path.join(os.path.expanduser("~"), "SolarFishingV5")
    return str(Path(__file__).parent.resolve())

def find_bundled_configs(resource_path, exe_dir):
    """Locate the packaged configs folder shipped with the onedir build."""
    candidates = [
        os.path.join(resource_path, "configs"),
        os.path.join(exe_dir, "configs"),
        os.path.join(exe_dir, "_internal", "configs"),
    ]
    for path in candidates:
        if os.path.isdir(path):
            return path
    return candidates[0]

def seed_configs_from_bundle(bundled_configs, configs_path):
    """If AppData has no configs folder, copy the packaged defaults into it."""
    if os.path.isdir(configs_path):
        return
    if os.path.isdir(bundled_configs):
        shutil.copytree(bundled_configs, configs_path)
    else:
        os.makedirs(configs_path, exist_ok=True)

# Establish Paths For Solar Fishing V5
RESOURCE_PATH = str(get_resource_path())
EXE_DIR = str(get_exe_dir())
IS_COMPILED = _is_frozen()
APPDATA_PATH = get_appdata_path()
# Writable Files (Last_Config.Json, Debug Shots, Logs) Live Here.
# Compiled → Appdata; Dev → Project Directory.
BASE_PATH = APPDATA_PATH if IS_COMPILED else RESOURCE_PATH
os.makedirs(BASE_PATH, exist_ok=True)
IMAGES_PATH = os.path.join(RESOURCE_PATH, "images")
UI_PATH = os.path.join(RESOURCE_PATH, "ui")
if IS_COMPILED:
    CONFIGS_PATH = os.path.join(APPDATA_PATH, "configs")
    BUNDLED_CONFIGS_PATH = find_bundled_configs(RESOURCE_PATH, EXE_DIR)
    seed_configs_from_bundle(BUNDLED_CONFIGS_PATH, CONFIGS_PATH)
else:
    BUNDLED_CONFIGS_PATH = os.path.join(RESOURCE_PATH, "configs")
    CONFIGS_PATH = BUNDLED_CONFIGS_PATH
LAST_CONFIG = os.path.join(BASE_PATH, "last_config.json")
# File Management
def open_folder(folder):
    if sys.platform == "win32":
        os.startfile(folder)
    elif sys.platform == "darwin":  # Macos
        subprocess.run(["open", folder])
    else:  # Linux
        subprocess.run(["xdg-open", folder])

def open_base_folder():
    # Writable User Data (Configs, Debug Shots, Logs)
    open_folder(BASE_PATH)
# Central Area Definitions.  To Add A New Selectable Area:
# 1. Add An Entry Below (Key, Color, Label, Default Ratios 0–1).
# 2. That'S It — Selector Ui, Save/Load, Defaults, And The Show/Hide Menu
#      all pick it up automatically.  Use get_areas("your_key") later if needed.
AREA_CONFIG = {
    "shake": {
        "color": "#df0000",
        "label": "Shake Box",
        "default": {"x": 0.1041, "y": 0.0925, "width": 0.7917, "height": 0.6963},
    },
    "fish": {
        "color": "#00beff",
        "label": "Fish Box",
        "default": {"x": 0.2844, "y": 0.7981, "width": 0.4297, "height": 0.0389},
    },
    "friend": {
        "color": "#ffed00",
        "label": "Friend Box (Fish End)",
        "default": {"x": 0.0046, "y": 0.8583, "width": 0.0355, "height": 0.0817},
    },
}
# Display / Iteration Order (Also Used For Numberkey Toggles 1–9 In The Selector)
AREA_ORDER = list(AREA_CONFIG.keys())
class AreaSelector:
    """
    Fullscreen transparent overlay implemented as a second pywebview window.
    Long-lived instance: call show() / hide() / update() as needed.
    Areas are fully data-driven via the module-level AREA_CONFIG / AREA_ORDER.
    Adding a new area requires only a new entry in AREA_CONFIG.
    """
    # Prevent Pywebview From Walking This Object When The Main Api Is Js_Api
    # (Window.Native.Accessibilityobject.Bounds Recursion / Webview2 Com).
    _serializable = False
    HTML_FILE = os.path.join(UI_PATH, "area_selector.html")
    def __init__(self, parent_app):
        self.parent_app = parent_app
        self.area_window = None
        self._open = False
        self._areas = {}
        self._visible = {name: True for name in AREA_ORDER}
        self._screen_capture = None
        self._screenshot_b64 = None
        # Css Client Size Of The Overlay (Reported By Js). Used For Pixel↔Ratio
        # Conversion So Boxes Align When Display Scale ≠ 100%. Falls Back To
        # Screen_* Until Window_Ready Reports The Real Size.
        self._view_w = float(SCREEN_WIDTH)
        self._view_h = float(SCREEN_HEIGHT)
    def _capture_and_crop(self):
        """Capture full screen and remove the macOS menu bar strip so the
        image matches the frameless window geometry (no menu bar)."""
        frame = self.parent_app.capture_single_frame()
        if frame is None:
            return None

        if frame.ndim == 3 and frame.shape[2] == 4:
            frame = frame[:, :, :3].copy()
        menu_offset = get_macos_menu_offset()
        scale = get_scale_factor()
        if scale <= 0:
            scale = 1.0
        self._scale = scale
        if menu_offset > 0:
            crop = int(round(menu_offset * scale))
            if 0 < crop < frame.shape[0]:
                frame = frame[crop:, :, :].copy()
        frame = np.clip(frame.astype(np.int16) - 15, 0, 255).astype(np.uint8)
        return frame

    def _encode_screenshot(self, frame):
        """Encode BGR NumPy frame as a JPEG data-URL for the canvas."""
        if frame is None:
            return None

        try:

            # BGR → RGB without OpenCV
            rgb_frame = frame[:, :, ::-1]

            img = Image.fromarray(rgb_frame, "RGB")

            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=85)

            b64 = base64.b64encode(buf.getvalue()).decode("ascii")
            return "data:image/jpeg;base64," + b64

        except Exception:
            return None

    def show(self):
        """Thin js_api object — only exposes the methods the HTML page calls.
        Do NOT pass `self` (or any object that holds a reference to the
        pywebview Window): on macOS Cocoa that triggers infinite recursion
        via AccessibilityObject.Bounds."""
        outer = self
        class _AreaApi:
            def get_area_config(self):
                return outer.get_area_config()

            def set_visibility(self, visible_dict):
                return outer.set_visibility(visible_dict)

            def get_areas(self):
                return outer.get_areas()

            def on_mouse_move(self, mouse_x, mouse_y, current_boxes):
                return outer.on_mouse_move(mouse_x, mouse_y, current_boxes)

            def on_point_select(self, name, xr, yr):
                return outer.on_point_select(name, xr, yr)

            def save_areas(self, areas):
                return outer.save_areas(areas)

            def get_screenshot_data(self):
                return outer.get_screenshot_data()

            def window_ready(self, win_x, win_y, width=None, height=None):
                return outer.window_ready(win_x, win_y, width, height)

        if self._open and self.area_window:
            return

        self._screen_capture = self._capture_and_crop()
        self._screenshot_b64 = self._encode_screenshot(self._screen_capture)
        menu_offset = get_macos_menu_offset()
        # Default View Size Until Js Reports The Real Css Client Size.
        # At Scale ≠ 100% These Often Differ From Screen_* (Physical).
        self._view_w = float(SCREEN_WIDTH)
        self._view_h = float(max(1, SCREEN_HEIGHT - menu_offset))
        self.area_window = webview.create_window(
            "Area Selector", self.HTML_FILE, js_api=_AreaApi(),
            transparent=True, frameless=True, easy_drag=False, on_top=True,
            resizable=False, width=SCREEN_WIDTH, height=SCREEN_HEIGHT - menu_offset,
            x=SCREEN_LEFT, y=SCREEN_TOP, background_color="#000000",
        )
        self._open = True
        self.area_window.events.closed += self._on_closed
        if sys.platform == "win32":
            def maximize_area_selector():
                try:
                    hwnd = _get_hwnd(self.area_window)
                    if hwnd:
                        user32.ShowWindow(wintypes.HWND(hwnd), SW_MAXIMIZE)
                except Exception as e:
                    try:
                        self.parent_app.set_status(f"Failed to maximize area selector: {e}")
                    except Exception:
                        print("Failed to maximize area selector:", e)
            self.area_window.events.shown += maximize_area_selector
    def _to_ratios(self, area):
        """Accept normalized areas and legacy pixel areas, store normalized values."""
        if not isinstance(area, dict):
            return {"x": 0.0, "y": 0.0, "width": 0.0, "height": 0.0}

        values = {
            "x": float(area.get("x", 0)),
            "y": float(area.get("y", 0)),
            "width": float(area.get("width", area.get("w", 0))),
            "height": float(area.get("height", area.get("h", 0))),
        }
        if any(abs(values[key]) > 1 for key in values):
            values["x"] /= SCREEN_WIDTH
            values["y"] /= SCREEN_HEIGHT
            values["width"] /= SCREEN_WIDTH
            values["height"] /= SCREEN_HEIGHT
        return values

    def update(self, area_name, area_dict):
        """Set one area by name (ratios or legacy pixels)."""
        self._areas[area_name] = self._to_ratios(area_dict)
    def update_all(self, areas_dict):
        """Bulk-load every known area from a {name: dict} mapping."""
        for name in AREA_ORDER:
            src = (areas_dict or {}).get(name)
            if not isinstance(src, dict):
                src = AREA_CONFIG[name]["default"]
            self._areas[name] = self._to_ratios(src)
    def get_area_config(self):
        """Return colours, labels, order and visibility so JS stays data-driven."""
        return {

            "order": list(AREA_ORDER),
            "areas": {
                name: {"color": cfg["color"], "label": cfg["label"]}
                for name, cfg in AREA_CONFIG.items()
            },
            "visible": dict(self._visible),
        }
    def set_visibility(self, visible_dict):
        """Keep Python in sync when the overlay panel toggles boxes."""
        if isinstance(visible_dict, dict):
            for name, val in visible_dict.items():
                if name in self._visible:
                    self._visible[name] = bool(val)
    def get_areas(self):
        """Return canvas-relative pixel boxes for JS (menu-bar offset subtracted).
        Uses the CSS client size reported by the page (_view_w / _view_h) so
        boxes line up with the canvas at any display scale. Falls back to
        SCREEN_* only before window_ready has reported the real size.
        """
        menu_offset = get_macos_menu_offset()
        vw = float(self._view_w) if self._view_w and self._view_w > 0 else float(SCREEN_WIDTH)
        vh = float(self._view_h) if self._view_h and self._view_h > 0 else float(max(1, SCREEN_HEIGHT - menu_offset))
        # Reconstruct Fullscreen Height In The Same Units As The View So
        # Stored Ratios (Relative To The Full Screen Including Menu Bar)
        # Map Correctly Into The Overlay'S Client Coordinate Space.
        full_h = vh + float(menu_offset)
        result = {}
        for name, area in self._areas.items():
            result[name] = {
                "x": area["x"] * vw,
                "y": area["y"] * full_h - menu_offset,
                "width": area["width"] * vw,
                "height": area["height"] * full_h,
            }
        return result

    def on_mouse_move(self, mouse_x, mouse_y, current_boxes):
        if not self._open:
            return

        menu_offset = get_macos_menu_offset()
        for name in AREA_ORDER:
            box = current_boxes.get(name, {})
            if box:
                self._areas[name] = self._pixels_to_ratios(box, menu_offset)
            b = current_boxes.get(name)
            if b and self._visible.get(name, True):
                bx, by = float(b.get("x", 0)), float(b.get("y", 0))
                bw = float(b.get("width", b.get("w", 0)) or 1)
                bh = float(b.get("height", b.get("h", 0)) or 1)
                mx, my = float(mouse_x or 0), float(mouse_y or 0)
                if bx <= mx <= bx + bw and by <= my <= by + bh:
                    xr = round((mx - bx) / bw, 2)
                    yr = round((my - by) / bh, 2)
                    try:
                        self.parent_app.set_status(f"{name.upper()} → X: {xr:.2f}  Y: {yr:.2f}")
                    except Exception:
                        pass

                    break

    def on_point_select(self, name, xr, yr):
        """Called by JS when Select Point mode is on and user clicks.
        Click inside an area → ratios relative to that area box.
        Click outside any area → full-screen (viewport) ratios 0–1 under the
        name "screen". Shows ratios in the status bar and closes the selector
        without the generic 'Area selector closed' message so the ratios remain visible."""
        if not self._open:
            return

        try:
            xr = float(xr)
            yr = float(yr)
        except (TypeError, ValueError):
            return

        xr = max(0.0, min(1.0, xr))
        yr = max(0.0, min(1.0, yr))
        # name may be None / "screen" / unknown when the click missed every box
        if not name or name == "screen" or name not in AREA_CONFIG:
            label = "SCREEN"
        else:
            label = (AREA_CONFIG.get(name) or {}).get("label", name)
        status_msg = f"{label.upper()}  →  X RATIO: {xr:.4f}  Y RATIO: {yr:.4f}"
        # Persist Current Areas, Then Close Without Overwriting The Ratio Status.
        try:
            self.parent_app.bar_areas.update(self._areas)
            self.parent_app.save_misc_settings()
        except Exception:
            pass

        self._open = False
        try:
            self.parent_app.set_status(status_msg)
        except Exception:
            pass

        if self.area_window:
            try:
                self.area_window.destroy()
            except Exception:
                pass

    def _pixels_to_ratios(self, box, menu_offset=0):
        """Convert JS canvas-pixel boxes back to full-screen ratios.
        Divides by the CSS client size (_view_w / _view_h) reported by the
        page so the ratio is correct even when that size differs from
        SCREEN_WIDTH / SCREEN_HEIGHT (common at display scale ≠ 100%).
        """
        vw = float(self._view_w) if self._view_w and self._view_w > 0 else float(SCREEN_WIDTH)
        vh = float(self._view_h) if self._view_h and self._view_h > 0 else float(max(1, SCREEN_HEIGHT - menu_offset))
        full_h = vh + float(menu_offset)
        if vw <= 0:
            vw = 1.0
        if full_h <= 0:
            full_h = 1.0
        return {

            "x": float(box.get("x", 0)) / vw,
            "y": (float(box.get("y", 0)) + menu_offset) / full_h,
            "width": float(box.get("width", box.get("w", 0))) / vw,
            "height": float(box.get("height", box.get("h", 0))) / full_h,
        }
    def window_ready(self, win_x, win_y, width=None, height=None):
        """JS signals the page is ready — record CSS client size and push screenshot.
        width/height are window.innerWidth / innerHeight (CSS pixels). Using
        these for box conversion fixes the off-screen drawing that happens
        when display scale ≠ 100% and SCREEN_* (physical) ≠ canvas size.
        """
        try:
            if width is not None and height is not None:
                w = float(width)
                h = float(height)
                if w > 0 and h > 0:
                    self._view_w = w
                    self._view_h = h
        except (TypeError, ValueError):
            pass

        if self._screenshot_b64 and self.area_window and self._open:
            # Inject Via A Short Data Reference; Js Stores It And Draws.
            try:
                # Pass As Return Value Of A Dedicated Getter Instead Of
                # Embedding A Huge String In Evaluate_Js When Possible.
                self.area_window.evaluate_js(
                    "window.__applyScreenshot && window.__applyScreenshot()"
                )
            except Exception:
                pass

        return None

    def save_areas(self, areas):
        if not self._open:
            return

        menu_offset = get_macos_menu_offset()
        for name in AREA_ORDER:
            if name in areas:
                self._areas[name] = self._pixels_to_ratios(areas[name], menu_offset)
        self.parent_app.bar_areas.update(self._areas)
        self.parent_app.save_misc_settings()
        self._open = False
        self.parent_app.set_status("Area selector closed")
        if self.area_window:
            try:
                self.area_window.destroy()
            except Exception:
                pass

    def get_screenshot_data(self):
        """Return the data-URL of the frozen (menu-bar-cropped) screenshot."""
        return self._screenshot_b64 or ""

    def _on_closed(self):
        if self._open:
            self.parent_app.bar_areas.update(self._areas)
            self.parent_app.save_misc_settings()
            self.parent_app.set_status("Area selector closed")
        self.area_window = None
        self._open = False
    def is_open(self):
        return self._open and self.area_window is not None

    def hide(self):
        if self.is_open():
            self.close()
    def close(self):
        if self.is_open():
            self.save_areas(self.get_areas())
# Eyedropper Class
class Eyedropper:
    """
    Fullscreen transparent overlay for color picking using pywebview.
    Captures a frozen screenshot (menu bar cropped so it matches the
    frameless window), renders it in the canvas, and returns the picked color.
    """
    # Prevent Pywebview From Walking This Object When The Main Api Is Js_Api
    # (Window.Native.Accessibilityobject.Bounds Recursion / Webview2 Com).
    _serializable = False
    HTML_FILE = os.path.join(UI_PATH, "eyedropper.html")
    def __init__(self, parent_app):
        self.parent = parent_app
        self.eyedropper_window = None
        self._open = False
        self._visible = False
        self.last_picked_color = None
        self._cancelled = False
        self._color_key = None
        self._scale = 1.0
        self._screen_capture = None
        self._screenshot_b64 = None
        self.left = 0
        self.top = 0
        self.width = 0
        self.height = 0
    def _capture_and_crop(self):
        """Capture full screen and remove the macOS menu bar strip so the
        image matches the frameless window geometry (no menu bar)."""
        frame = self.parent.capture_single_frame()
        if frame is None:
            return None

        if frame.ndim == 3 and frame.shape[2] == 4:
            frame = frame[:, :, :3].copy()
        menu_offset = get_macos_menu_offset()
        scale = get_scale_factor()
        if scale <= 0:
            scale = 1.0
        self._scale = scale
        if menu_offset > 0:
            crop = int(round(menu_offset * scale))
            if 0 < crop < frame.shape[0]:
                frame = frame[crop:, :, :].copy()
        return frame

    def _encode_screenshot(self, frame):
        """Encode BGR NumPy frame as a JPEG data-URL for the canvas."""
        if frame is None:
            return None

        try:

            # BGR → RGB without OpenCV
            rgb_frame = frame[:, :, ::-1]

            img = Image.fromarray(rgb_frame, "RGB")

            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=85)

            b64 = base64.b64encode(buf.getvalue()).decode("ascii")
            return "data:image/jpeg;base64," + b64

        except Exception:
            return None

    def show(self, color_key=None):
        """Open the eyedropper overlay. Optional color_key is the settings
        field that should receive the picked color (e.g. 'fish_color').
        Thin js_api object — only exposes the methods the HTML page calls.
        Do NOT pass `self` (or any object that holds a reference to the
        pywebview Window): on macOS Cocoa that triggers infinite recursion
        via AccessibilityObject.Bounds (same crash previously fixed for
        AreaSelector).
        """
        if self._open and self.eyedropper_window:
            return

        outer = self
        class _EyedropperApi:
            def window_ready(self, win_x, win_y):
                return outer.window_ready(win_x, win_y)

            def get_screenshot_data(self):
                return outer.get_screenshot_data()

            def get_pixel_at(self, x, y):
                return outer.get_pixel_at(x, y)

            def pick_color(self, hex_color):
                return outer.pick_color(hex_color)

            def close_eyedropper(self):
                return outer.close_eyedropper()

        self.last_picked_color = None
        self._cancelled = False
        self._color_key = color_key
        self._screen_capture = self._capture_and_crop()
        self._screenshot_b64 = self._encode_screenshot(self._screen_capture)
        menu_offset = get_macos_menu_offset()
        win_h = max(1, SCREEN_HEIGHT - menu_offset)
        self.left = SCREEN_LEFT
        self.top = SCREEN_TOP
        self.width = SCREEN_WIDTH
        self.height = win_h
        self.eyedropper_window = webview.create_window(
            "Eyedropper",
            self.HTML_FILE,
            js_api=_EyedropperApi(),
            transparent=True,
            frameless=True,
            easy_drag=False,
            on_top=True,
            resizable=False,
            width=self.width,
            height=self.height,
            x=self.left,
            y=self.top,
            background_color="#000000",
        )
        self._open = True
        self._visible = True
        self.eyedropper_window.events.closed += self._on_closed
        if sys.platform == "win32":
            # Maximize On Windows After The Window Is Created
            def maximize_area_selector():
                try:
                    hwnd = _get_hwnd(self.eyedropper_window)
                    if hwnd:
                        user32.ShowWindow(wintypes.HWND(hwnd), SW_MAXIMIZE)
                except Exception as e:
                    self.parent.set_status("Failed to maximize area selector:", e)
            self.eyedropper_window.events.shown += maximize_area_selector
        try:
            self.parent.set_status(
                "Eyedropper opened • Hover to preview • Click to pick • Esc to cancel"
            )
        except Exception:
            pass

    def is_open(self):
        return self._open and self.eyedropper_window is not None

    def hide(self):
        """Destroys the current window instance completely.
        Clear _open first to avoid concurrent evaluate_js on a disposed WebView2."""
        if self.eyedropper_window and self._open:
            self._open = False
            self._visible = False
            try:
                self.eyedropper_window.destroy()
            except Exception:
                pass
            self._on_closed()
    def close(self):
        """Alias used by shutdown / toggle paths."""
        self.hide()
    # ── Js Api Methods (Called From Eyedropper.Html) ──
    def window_ready(self, win_x, win_y):
        """JS signals the page is ready — push the frozen screenshot."""
        if self._screenshot_b64 and self.eyedropper_window and self._open:
            # Inject Via A Short Data Reference; Js Stores It And Draws.
            try:
                # Pass As Return Value Of A Dedicated Getter Instead Of
                # Embedding A Huge String In Evaluate_Js When Possible.
                self.eyedropper_window.evaluate_js(
                    "window.__applyScreenshot && window.__applyScreenshot()"
                )
            except Exception:
                pass

        return None

    def get_screenshot_data(self):
        """Return the data-URL of the frozen (menu-bar-cropped) screenshot."""
        return self._screenshot_b64 or ""

    def get_pixel_at(self, x, y):
        """Sample the frozen capture at logical canvas coordinates (x, y).
        Menu bar was already cropped out, so no y-offset is needed."""
        if not self.is_open():
            return "#000000"

        frame = self._screen_capture
        if frame is None:
            return "#000000"

        scale = self._scale if self._scale > 0 else 1.0
        px = int(x * scale)
        py = int(y * scale)
        if px < 0 or py < 0 or py >= frame.shape[0] or px >= frame.shape[1]:
            return "#000000"

        b = int(frame[py, px, 0])
        g = int(frame[py, px, 1])
        r = int(frame[py, px, 2])
        hex_color = f"#{r:02X}{g:02X}{b:02X}"
        try:
            self.parent.set_status(f"{hex_color} • Click to pick • Esc to cancel")
        except Exception:
            pass

        return hex_color

    def pick_color(self, hex_color):
        """Called by JS when user clicks to pick a color.
        Stores the color, pushes it to the main UI, and closes the overlay."""
        if not self.is_open():
            return None

        if not hex_color or not isinstance(hex_color, str):
            return None

        hex_color = hex_color.strip()
        if not hex_color.startswith("#"):
            hex_color = "#" + hex_color
        self.last_picked_color = hex_color
        self._cancelled = False
        # Write Into Settings Vars When A Target Key Was Provided
        color_key = self._color_key
        if color_key:
            try:
                self.parent.vars[color_key] = hex_color
            except Exception:
                pass

        # Notify The Main Webview So The Color Input Updates
        self._notify_main_ui(hex_color, color_key)
        try:
            self.parent.set_status(f"Picked color: {hex_color}")
        except Exception:
            pass

        self.hide()
        return hex_color

    def close_eyedropper(self):
        """Called by JS on Escape — cancel without picking."""
        if not self.is_open():
            return

        self._cancelled = True
        self.last_picked_color = None
        try:
            self.parent.set_status("Eyedropper cancelled")
        except Exception:
            pass

        self.hide()
    def _notify_main_ui(self, hex_color, color_key=None):
        """Push the picked color into the main pywebview window."""
        try:
            safe = hex_color.replace("\\", "\\\\").replace("'", "\\'").replace('"', '\\"')
            key_js = "null"
            if color_key:
                key_js = "'" + str(color_key).replace("\\", "\\\\").replace("'", "\\'") + "'"
            script = (
                f"(function(){{"
                f"var c='{safe}',k={key_js};"
                f"if(window.onColorPicked)window.onColorPicked(c,k);"
                f"if(window.setPickedColor)window.setPickedColor(c,k);"
                f"if(k){{var el=document.getElementById(k)||document.querySelector('[data-color-key=\"'+k+'\"]')"
                f"||document.querySelector('input[name=\"'+k+'\"]');"
                f"if(el){{el.value=c;el.dispatchEvent(new Event('input',{{bubbles:true}}));"
                f"el.dispatchEvent(new Event('change',{{bubbles:true}}));}}"
                f"}}"
                f"}})()"
            )
            # Main Window Is The First Created Window
            if webview.windows:
                webview.windows[0].evaluate_js(script)
        except Exception:
            pass

    def _on_closed(self, *args):
        """Lifecycle cleanup when the overlay is destroyed."""
        self.eyedropper_window = None
        self._open = False
        self._visible = False
        self._screenshot_b64 = None
        # Keep Last_Picked_Color So The Main Ui Can Still Poll It
class FishOverlay:
    # Prevent Pywebview From Walking This Object When The Main Api Is Js_Api
    # (Window.Native.Accessibilityobject.Bounds Recursion / Webview2 Com).
    _serializable = False
    HTML_FILE = os.path.join(UI_PATH, "fish_overlay.html")
    def __init__(self, parent_app):
        self.parent_app = parent_app
        self._overlay_window = None
        self._open = False
        self._visible = False
        # Track Active Viewport Geometry (Logical Points For Pywebview)
        self.left = 0
        self.top = 0
        self.width = 0
        self.height = 0
    def _to_window_coords(self, left, top, width, height):
        """
        Convert physical-pixel geometry (from _get_areas / capture) into the
        logical points pywebview expects for window x/y/width/height.
        On Windows scale is always 1; on macOS Retina it is typically 2.0.
        Also clamps width/height so a bad (e.g. post-reset) size cannot make
        the overlay cover the entire screen or exceed monitor bounds.
        """
        scale = get_scale_factor()
        if scale <= 0:
            scale = 1.0
        left = int(left / scale)
        top = int(top / scale)
        width = max(1, int(width / scale))
        height = max(1, int(height / scale))
        # Clamp So The Window Stays Onscreen (Logical Screen Size)
        screen_w = max(1, SCREEN_WIDTH)
        screen_h = max(1, SCREEN_HEIGHT)
        width = min(width, screen_w)
        height = min(height, screen_h)
        left = max(0, min(left, max(0, screen_w - width)))
        top = max(0, min(top, max(0, screen_h - height)))
        return left, top, width, height

    def show(self, left, top, width, height):
        """Creates and displays the transparent frameless overlay window.
        Arguments are physical-pixel screen coordinates (same space as
        _get_areas / capture_frame). They are converted to logical points
        for pywebview.
        """
        left, top, width, height = self._to_window_coords(left, top, width, height)
        if self._open and self._overlay_window:
            # If Already Open, Shift/Resize It Instead Of Duplicating
            self.resize(left, top, width, height, already_logical=True)
            return

        self.left = left
        self.top = top
        self.width = width
        self.height = height
        self._overlay_window = webview.create_window(
            "Fish Overlay",
            url=self.HTML_FILE,
            transparent=False,
            frameless=True,
            easy_drag=False,
            on_top=True,
            resizable=False,
            width=self.width,
            height=self.height,
            x=self.left,
            y=self.top,
            background_color="#ffffff",
            min_size=(0.03 * SCREEN_WIDTH, 0.05 * SCREEN_HEIGHT),
        )
        self._open = True
        self._visible = True
        self._overlay_window.events.closed += self._on_closed
    def hide(self):
        """Destroys the current window instance completely.
        Clear _open BEFORE destroy so concurrent minigame threads that still
        call clear()/draw_box()/_eval skip the disposed WebView2 and avoid
        ObjectDisposedException (logged by pywebview as 'Error occurred in script').
        """
        if self._overlay_window and self._open:
            self._open = False
            self._visible = False
            try:
                self._overlay_window.destroy()
            except Exception:
                pass
            self._on_closed()
    def resize(self, left, top, width, height, already_logical=False):
        """Resizes and moves the window dynamically if it exists.
        By default arguments are physical pixels (same as show()).
        Pass already_logical=True when the caller has already converted them.
        """
        if not already_logical:
            left, top, width, height = self._to_window_coords(left, top, width, height)
        self.left = left
        self.top = top
        self.width = width
        self.height = height
        if self._overlay_window and self._open:
            try:
                self._overlay_window.move(self.left, self.top)
                self._overlay_window.resize(self.width, self.height)
            except Exception:
                # Window May Already Be Disposed (Race With Stop_Macro / Hide)
                self._open = False
                self._overlay_window = None
    def clear(self):
        """Clears rendering elements inside the web view context."""
        self._eval("window.fishOverlay && window.fishOverlay.clear()")
    def draw_box(self, x1, y1, x2, y2, color, show_bar_center=False):
        """Evaluates JS drawing contexts based on calculations inside the viewport.
        bar_center / box_size / canvas_offset are in physical pixels relative to
        the fish capture region; they are converted to logical CSS pixels for
        the overlay canvas (which matches the logical window size).
        """
        # Ensure The Overlay Exists Before Trying To Execute Scripts On It
        if not self._open or not self._overlay_window:
            return

        # Failsafe if shape is None
        if x1 is None:
            return

        scale = get_scale_factor()
        if scale <= 0:
            scale = 1.0
        shape = {
            "x1": int(x1 / scale),
            "y1": int(y1 / scale),
            "x2": int(x2 / scale),
            "y2": int(y2 / scale),
            "color": str(color),
            "show_bar_center": bool(show_bar_center)
        }
        self._eval(f"window.fishOverlay && window.fishOverlay.draw({json.dumps(shape)})")
    def _eval(self, script):
        """Safely executes JavaScript strings within the running window environment.
        Catches ObjectDisposedException (and any other failure) that can occur
        when the overlay is destroyed from another thread while the minigame
        loop is still drawing."""
        if not (self._overlay_window and self._open):
            return
        try:
            self._overlay_window.evaluate_js(script)
        except Exception:
            # Webview2 May Already Be Disposed; Mark Closed So We Stop Trying
            self._open = False
            self._overlay_window = None
    def _on_closed(self):
        """Internal callback cleaning lifecycle states upon execution exit."""
        self._overlay_window = None
        self._open = False
        self._visible = False
class Api:
    def __init__(self):
        self.vars = {} # Save Entry Variables Here
        self.current_config = self.get_last_config()
        self.load_settings_into_vars(self.current_config)
        # Start Hotkey Listener
        try:
            self.key_listener = KeyListener(on_press=self.on_key_press)
            self.key_listener.daemon = True
            self.key_listener.start()
        except Exception as e:
            self.set_status(f"Key Listener error: {e}")
        # Store Screen Width And Height To Use Later
        self.SCREEN_WIDTH = SCREEN_WIDTH
        self.SCREEN_HEIGHT = SCREEN_HEIGHT
        self.SCREEN_LEFT = SCREEN_LEFT
        self.SCREEN_TOP = SCREEN_TOP
        self.SCREEN_SCALE = ((self.SCREEN_WIDTH / 1920) + (self.SCREEN_HEIGHT / 1080)) / 2
        # Macro State
        self.macro_running = False
        self.macro_thread = None
        # Safe Defaults Before Key Listener Starts (Will Be Overwritten By Load_Misc_Settings)
        self.bar_areas = {name: None for name in AREA_ORDER}
        self.current_rod_name = "Default"
        self.scale_x_1440 = self.SCREEN_WIDTH / 2560
        self.scale_y_1440 = self.SCREEN_HEIGHT / 1440
        # Screen Capture
        self.capture_thread = None
        self.capture_frame = None
        self.capture_id = 0
        self.scan_delay = 0.1
        # Other classes
        self.area_selector = AreaSelector(self)
        self.eyedropper = Eyedropper(self)
        self.fish_overlay = FishOverlay(self)
        # Load Settings
        self.load_misc_settings()
    def _refresh_screen_dimensions(self):
        """
        Re-query mss for the primary monitor's current resolution and update all
        screen-dimension instance variables.  Call this whenever the capture monitor
        changes (hot-plug, resolution switch, etc.) so that _get_areas, the capture pipelines,
        and the fish-overlay layout all use the correct pixel dimensions.
        Invalidating _thread_local forces the capture pipelines to rebuild its cached
        monitor dict on the next capture call.
        """
        with MSS() as _sct:
            if len(_sct.monitors) > 1:
                _m = _sct.monitors[1]
            else:
                _m = _sct.monitors[0]
        self.SCREEN_WIDTH  = _m["width"]
        self.SCREEN_HEIGHT = _m["height"]
        self.SCREEN_LEFT   = _m["left"]
        self.SCREEN_TOP    = _m["top"]
        self.SCREEN_SCALE  = ((self.SCREEN_WIDTH / 1920) + (self.SCREEN_HEIGHT / 1080)) / 2
        self.scale_x_1440  = self.SCREEN_WIDTH  / 2560
        self.scale_y_1440  = self.SCREEN_HEIGHT / 1440
        # Force the capture pipelines to rebuild the thread-local monitor dict.
        self._thread_local = threading.local()
    # Save Config
    def _get_prompt_defaults(self):
        defaults = {}
        index_path = os.path.join(UI_PATH, "index.html")
        try:
            with open(index_path, "r", encoding="utf-8") as f:
                html = f.read()
        except Exception:
            return defaults

        input_pattern = re.compile(r"<input\b(?=[^>]*\bid\s*=\s*['\"]?([^'\"\s>]+))" r"(?=[^>]*\bplaceholder\s*=\s*['\"]([^'\"]*)['\"])[^>]*>", re.IGNORECASE,)
        for field_id, placeholder in input_pattern.findall(html):
            prompt = placeholder.strip()
            defaults[field_id] = prompt
        select_pattern = re.compile( r"<select\b(?=[^>]*\bid\s*=\s*['\"]?([^'\"\s>]+))[^>]*>" r"(.*?)</select>", re.IGNORECASE | re.DOTALL, )
        option_pattern = re.compile( r"<option\b[^>]*\bvalue\s*=\s*['\"]?([^'\"\s>]+)", re.IGNORECASE, )
        for field_id, body in select_pattern.findall(html):
            match = option_pattern.search(body)
            if match:
                defaults[field_id] = match.group(1).strip()
        return defaults

    def _get_saved_default_config(self):
        default_path = os.path.join(CONFIGS_PATH, "Default", "config.json")
        try:
            with open(default_path, "r") as f:
                data = json.load(f)
            return data if isinstance(data, dict) else {}

        except Exception:
            return {}

    def _get_config_defaults(self):
        defaults = self._get_saved_default_config()
        defaults.update(self._get_prompt_defaults())
        if hasattr(self, "default_settings_data"):
            defaults.update(getattr(self, "default_settings_data", {}))
        return defaults

    def _fill_blank_settings(self, settings):
        clean_settings = dict(settings or {})
        defaults = self._get_config_defaults()
        for key, value in list(clean_settings.items()):
            if isinstance(value, str) and value.strip() == "" and key in defaults:
                clean_settings[key] = defaults[key]
        return clean_settings

    def _load_config_data(self, config_name):
        config_path = os.path.join(CONFIGS_PATH, config_name, "config.json")
        with open(config_path, "r") as f:
            settings = json.load(f)
        settings = self._fill_blank_settings(settings)
        return settings, config_path

    def save_config(self, config_name, settings, text="Settings saved"):
        try:
            if not config_name:
                return {"success": False, "error": "No config selected."}

            folder = os.path.join(CONFIGS_PATH,config_name)
            os.makedirs(folder, exist_ok=True)
            settings = self._fill_blank_settings(settings)
            self.vars.update(settings)
            self.current_config = config_name
            self.save_last_config(config_name)
            config_path = os.path.join( folder, "config.json" )
            with open(config_path, "w") as f:
                json.dump(settings,f,indent=4)
            self.set_status(text)
            return {"success": True}

        except Exception as e:
            return {"success": False, "error": str(e)}

    # Load Config
    def load_config(self, config_name):
        try:
            if not config_name:
                return {"success": False, "error": "No config selected."}

            settings, config_path = self._load_config_data(config_name)
            with open(config_path, "w") as f:
                json.dump(settings,f,indent=4)
            self.vars = settings.copy()
            self.current_config = config_name
            self.save_last_config(config_name)
            return {"success": True, "settings": settings}

        except Exception as e:
            return {"success": False, "error": str(e)}

    # List Configs
    def list_configs(self):
        try:
            configs = sorted([folder for folder in os.listdir(CONFIGS_PATH) if os.path.isdir(os.path.join(CONFIGS_PATH, folder))])
            return configs

        except Exception:
            return []

    # Settings State
    def update_settings(self, settings):
        self.vars.update(settings)
        return {"success": True}

    def get_last_config(self):
        try:
            if os.path.exists(LAST_CONFIG):
                with open(LAST_CONFIG, "r") as f:
                    data = json.load(f)
                return data.get("last_config", "")

        except Exception:
            pass

        return ""

    def save_last_config(self, config_name):
        try:
            data = {}
            if os.path.exists(LAST_CONFIG):
                with open(LAST_CONFIG, "r") as f:
                    data = json.load(f)
            data["last_config"] = config_name
            with open(LAST_CONFIG, "w") as f:
                json.dump(data, f, indent=4)
        except Exception as e:
            self.set_status(f"Error saving last config: {e}")
    def resolve_config_name(self, config_name):
        configs = self.list_configs()
        if config_name in configs:
            return config_name

        for name in configs:
            if name.lower() == str(config_name).lower():
                return name

        return configs[0] if configs else ""

    def load_settings_into_vars(self, config_name):
        config_name = self.resolve_config_name(config_name)
        if not config_name:
            return

        try:
            settings, config_path = self._load_config_data(config_name)
            with open(config_path, "w") as f:
                json.dump(settings,f,indent=4)
            self.vars = settings
            self.current_config = config_name
            self.save_last_config(config_name)
        except Exception as e:
            self.set_status(f"Error loading config: {e}")
    def get_startup_config(self):
        config_name = self.resolve_config_name(self.current_config)
        if not config_name:
            return {

                "success": False,
                "error": "No configs found."
            }
        result = self.load_config(config_name)
        if result.get("success"):
            result["config_name"] = config_name
        return result

    # Delete Config
    def delete_config(self, config_name):
        try:
            folder = os.path.join( CONFIGS_PATH, config_name )
            config_path = os.path.join( folder, "config.json" )
            if os.path.exists(config_path):
                os.remove(config_path)
            if os.path.exists(folder):
                os.rmdir(folder)
            return { "success": True }

        except Exception as e:
            return { "success": False, "error": str(e) }

    def load_misc_settings(self):
        """Load miscellaneous settings from last_config.json."""
        # Defaults
        self.current_rod_name = "Default"
        self.bar_areas = {name: None for name in AREA_ORDER}
        # Default Hotkeys
        start_key  = "F5"
        change_key = "F6"
        stop_key   = "F7"
        try:
            path = os.path.join(BASE_PATH, "last_config.json")
            if not os.path.exists(path):
                return

            with open(path, "r") as f:
                data = json.load(f)
            # Bar Areas
            loaded_areas = data.get("bar_areas", {})
            for key in AREA_ORDER:
                area = loaded_areas.get(key)
                if isinstance(area, dict):
                    self.bar_areas[key] = {
                        "x": float(area.get("x", 0)),
                        "y": float(area.get("y", 0)),
                        "width": float(area.get("width", 0)),
                        "height": float(area.get("height", 0)),
                    }
            # Hotkeys
            start_key  = data.get("start_key", "F5")
            change_key = data.get("area_selector_key", "F6")
            stop_key   = data.get("stop_key", "F7")
        except Exception as e:
            self.set_status(f"Failed to load misc settings: {e}")
        # Convert Hotkeys
        self.hotkey_start = self._string_to_key(start_key)
        self.hotkey_area_selector_key = self._string_to_key(change_key)
        self.hotkey_stop = self._string_to_key(stop_key)
    def save_misc_settings(self):
        """Save miscellaneous settings."""
        path = os.path.join(BASE_PATH, "last_config.json")
        # Existing Data
        data = {}
        if os.path.exists(path):
            try:
                with open(path, "r") as f:
                    data = json.load(f)
            except:
                pass

        # Clean Areas
        clean_bar_areas = {}
        for key in AREA_ORDER:
            area = self.bar_areas.get(key)
            if isinstance(area, dict):
                clean_bar_areas[key] = {
                    "x": float(area.get("x", 0)),
                    "y": float(area.get("y", 0)),
                    "width": float(area.get("width", 0)),
                    "height": float(area.get("height", 0)),
                }
            else:
                clean_bar_areas[key] = None
        # Save
        data["bar_areas"] = clean_bar_areas
        # Hotkeys
        # data["start_key"] = self.vars["start_key"]
        # data["area_selector_key"] = self.vars["area_selector_key"]
        # data["stop_key"] = self.vars["stop_key"]
        with open(path, "w") as f:
            json.dump(data, f, indent=4)
    def open_base_folder(self):
        open_base_folder()
    def get_default_settings(self):
        return self._get_config_defaults()

    def get_default_colors(self):
        default_settings = self.get_default_settings()
        color_keys = [
            "left_color",
            "right_color",
            "arrow_color",
            "fish_color",
            "left_tolerance",
            "right_tolerance",
            "arrow_tolerance",
            "fish_tolerance",
            "shake_color",
            "shake_tolerance",
            "green_cast_color",
            "green_cast_tolerance",
            "white_cast_color",
            "white_cast_tolerance",
            "green_cast_color",
            "pinion_notes_tolerance",
            "friends_color",
            "friends_tolerance",
        ]
        return {

            key: default_settings[key]
            for key in color_keys
            if key in default_settings
        }
    def reset_settings(self, config_name):
        try:
            config_folder = os.path.join(
                CONFIGS_PATH,
                config_name
            )
            config_path = os.path.join(
                config_folder,
                "config.json"
            )
            os.makedirs(
                config_folder,
                exist_ok=True
            )
            existing_config = {}
            if os.path.exists(config_path):
                with open(config_path, "r") as f:
                    existing_config = json.load(f)
            # Full defaults
            default_settings = self.get_default_settings()
            # Preserve colors
            for color_key in self.get_default_colors().keys():
                if color_key in existing_config:
                    default_settings[color_key] = (
                        existing_config[color_key]
                    )
            with open(config_path, "w") as f:
                json.dump(
                    default_settings,
                    f,
                    indent=4
                )
            return {

                "success": True
            }
        except Exception as e:
            return {

                "success": False,
                "error": str(e)
            }
    def reset_colors(self, config_name):
        try:
            config_folder = os.path.join(
                CONFIGS_PATH,
                config_name
            )
            config_path = os.path.join(
                config_folder,
                "config.json"
            )
            os.makedirs(
                config_folder,
                exist_ok=True
            )
            if os.path.exists(config_path):
                with open(config_path, "r") as f:
                    config_data = json.load(f)
            else:
                config_data = {}
            # Reset only colors
            config_data.update(
                self.get_default_colors()
            )
            with open(config_path, "w") as f:
                json.dump(
                    config_data,
                    f,
                    indent=4
                )
            return {

                "success": True
            }
        except Exception as e:
            return {

                "success": False,
                "error": str(e)
            }
    def reset_areas(self):
        """Reset areas to default"""
        try:
            config_path = os.path.join(
                BASE_PATH,
                "last_config.json"
            )
            if not os.path.exists(config_path):
                return {
                    "success": True
                }
            with open(config_path, "r") as f:
                config_data = json.load(f)
            # Remove saved custom areas
            config_data.pop("bar_areas", None)
            with open(config_path, "w") as f:
                json.dump(config_data, f, indent=4)

            # Also reset the in-memory areas so they take effect immediately
            if hasattr(self, "bar_areas"):
                self.bar_areas = {}

            return {"success": True}

        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    def export_config(self, settings):
        try:
            path = webview.windows[0].create_file_dialog(
                webview.FileDialog.SAVE,
                save_filename="config.json"
            )
            if not path:
                return {"success": False, "error": "Cancelled"}

            if isinstance(path, (list, tuple)):
                path = path[0]
            with open(path, "w", encoding="utf-8") as f:
                json.dump(settings, f, indent=4)
            return {"success": True, "path": path}

        except Exception as e:
            return {"success": False, "error": str(e)}

    def open_link(self, url):
        """Open a URL in the default web browser."""
        try:
            webbrowser.open(url)
            return {

                "success": True
            }
        except Exception as e:
            return {

                "success": False,
                "error": str(e)
            }
    def get_macro_version(self):
        return APP_VERSION

    def set_status(self, message):
        """Push a status message to the main webview window's JS."""
        if IS_COMPILED == False:
            # print("Debug: ", message)
            pass
        try:
            safe = message.replace("\\", "\\\\").replace("`", "\\`").replace("'", "\\'")
            window.evaluate_js("window.setStatus && window.setStatus('" + safe + "')")
        except Exception:
            pass

    def message_box_javascript(self, message, clipboard_content):
        try:
            # Clean the error string so it doesn't break JavaScript execution syntax
            # We escape backslashes, single quotes, and newlines
            escaped_error = clipboard_content.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")
            # Construct the self-invoking JS code block
            js_code = f"""
            (function() {{
                let confirmed = confirm("{message}");
                if (confirmed) {{
                    navigator.clipboard.writeText('{escaped_error}')
                        .then(() => alert("Error log copied to clipboard!"))
                        .catch(err => alert("Failed to copy error: " + err));
                }}
            }})();
            """
            # Evaluate using the same 'window' reference your set_status uses
            window.evaluate_js(js_code)
        except Exception:
            pass # Keep it safe just like set_status

    def _get_scale_factor(self):
        return get_scale_factor()

    # Area Selector
    def open_area_selector(self):
        # Build current areas from bar_areas or AREA_CONFIG defaults (all keys, including appraisal)
        areas = {}
        for name in AREA_ORDER:
            a = self.bar_areas.get(name)
            areas[name] = a if isinstance(a, dict) else dict(AREA_CONFIG[name]["default"])

        if hasattr(self, "area_selector") and self.area_selector and self.area_selector.is_open():
            self.area_selector.hide()
        else:
            self.area_selector.show()
            self.area_selector.update_all(areas)
    # Debug Screenshots
    def take_debug_screenshot(self):
        """
        Capture every area in AREA_ORDER plus a full-screen shot, and save
        debug images as debug_<name>.png / debug_full.png.
        """
        full_img = self.capture_single_frame()
        if full_img is None:
            self.set_status("Full screen is empty")
            return

        try:
            # BGR → RGB without OpenCV
            rgb_img = full_img[:, :, ::-1]
            Image.fromarray(rgb_img, "RGB").save(
                os.path.join(BASE_PATH, "debug_full.png")
            )
        except Exception as e:
            self.set_status(f"Error saving full screenshot: {e}")
            return

        saved = ["full"]

        try:
            for name in AREA_ORDER:
                left, top, right, bottom, _, _ = self.get_areas(name)

                # Clamp to image bounds
                h, w = full_img.shape[:2]
                top = max(0, min(top, h - 1))
                bottom = max(top + 1, min(bottom, h))
                left = max(0, min(left, w - 1))
                right = max(left + 1, min(right, w))

                crop = full_img[top:bottom, left:right]

                if crop.size == 0:
                    continue

                # BGR → RGB without OpenCV
                rgb_crop = crop[:, :, ::-1]
                Image.fromarray(rgb_crop, "RGB").save(
                    os.path.join(BASE_PATH, f"debug_{name}.png")
                )

                saved.append(name)

        except Exception as e:
            self.set_status(f"Error saving region screenshots: {e}")
            return

        self.set_status(f"Saved debug screenshots ({', '.join(saved)})")

    # Hotkeys
    def _get_hotkeys(self):
        try:
            start_key = self.normalize_key(str(self.vars["start_key"]))
            areas_key = self.normalize_key(str(self.vars["area_selector_key"]))
            stop_key = self.normalize_key(str(self.vars["stop_key"]))
        except Exception as e:
            self.set_status(f"Get hotkeys failed: {e}")
            start_key = "f5"
            areas_key = "f6"
            stop_key = "f7"
        return start_key, areas_key, stop_key

    def normalize_key(self, key):
        try:
            return key.char.lower()  # Letter Keys

        except AttributeError:
            return str(key).replace("Key.", "").replace(" ", "").lower()

    def on_key_press(self, key):
        key = self.normalize_key(key)
        start_key, area_selector_key, stop_key = self._get_hotkeys()
        enable_hotkeys = self.vars["enable_hotkeys"]
        if not enable_hotkeys == "disabled":
            if key == start_key:
                window.hide()
                if self.macro_running == True:
                    return

                else:
                    # Set flag BEFORE starting threads to avoid race where
                    # the capture thread starts, sees macro_running=False, and exits immediately.
                    self.macro_running = True
                    # Save current settings to config before starting
                    self.save_config(self.current_config, self.vars)
                    if enable_hotkeys == "on":
                        self.macro_thread = threading.Thread(target=self.start_fishing, daemon=True)
                    self.macro_thread.start()
                    if sys.platform == "darwin":
                        self.capture_thread = threading.Thread(target=self.capture_loop_quartz, daemon=True)
                    else:
                        self.capture_thread = threading.Thread(target=self.capture_loop_mss, daemon=True)
                    self.capture_thread.start()
            elif key == area_selector_key:
                self.open_area_selector()
            elif key == stop_key:
                window.show()
                self.stop_macro()
        else:
            self.save_config(self.current_config, self.vars, f"Pressed: {key}")
    def _string_to_key(self, key_string):
        key_string = key_string.strip().lower()
        # Try Special Keys
        if hasattr(Key, key_string):
            return getattr(Key, key_string)

        # Fallback To Character
        return key_string

    # Keyboard/Mouse Functions (Platform-specific)
    # Hold Mouse
    def hold_mouse(self, mouse=False):
        "Hold mouse. True for right click, False for left click."
        if self.macro_running == False:
            return

        if sys.platform == "win32":
            if mouse:
                windll.mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
            else:
                windll.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        elif sys.platform == "darwin":
            _mouse_event(button="right" if mouse else "left", press=True)
        else:
            # Linux - now uses the unified X11 implementation
            _mouse_event(button="right" if mouse else "left", press=True)
    # Release Mouse
    def release_mouse(self, mouse=False):
        "Release mouse. True for right click, False for left click."
        if self.macro_running == False:
            return

        if sys.platform == "win32":
            if mouse:
                windll.mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
            else:
                windll.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        elif sys.platform == "darwin":
            _mouse_event(button="right" if mouse else "left", press=False)
        else:
            # Linux - now uses the unified X11 implementation
            _mouse_event(button="right" if mouse else "left", press=False)
    # Click At
    def _click_at(self, x, y, click_count=1):
        if self.macro_running == False:
            return

        # Convert coordinates if needed (Retina scaling)
        if sys.platform == "darwin":
            scale = self._get_scale_factor()
            x = int(x / scale)
            y = int(y / scale)
        # Seperate branches for Windows and macOS mouse events
        if sys.platform == "win32":
            windll.SetCursorPos(x, y)
            windll.mouse_event(MOUSEEVENTF_MOVE, 0, 1, 0, 0)
            for i in range(click_count):
                windll.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
                windll.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
                if i < click_count - 1:
                    time.sleep(0.03)
        else:
            _move_mouse(x, y)
            _move_mouse(x + 2, y + 2)
            _move_mouse(x, y)
            for i in range(click_count):
                _mouse_event(button="left", press=True)   # mouse down
                _mouse_event(button="left", press=False)  # mouse up
                if i < click_count - 1:
                    time.sleep(0.03)
    # Keyboard
    def _send_key(self, key2, delay=0.05, click_type=0):
        """
        Send a keyboard event.
        delay: Delay between send and release
        click_type:
            0 = click (press + release)   [default]
            1 = hold (press only)
            2 = release (release only)
        """
        if self.macro_running == False:
            return

        key = str(key2)
        if sys.platform == "darwin":
            send_key(key2, delay=delay, click_type=click_type)
        else:
            # Convert special key names
            special_keys = {
                "enter": Key.enter,
                "return": Key.enter,
                "tab": Key.tab,
                "space": Key.space,
                "esc": Key.esc,
                "escape": Key.esc,
                "backspace": Key.backspace,
                "delete": Key.delete,
                "up": Key.up,
                "down": Key.down,
                "left": Key.left,
                "right": Key.right,
            }
            key = special_keys.get(key.lower(), key)
            try:
                if click_type == 0:
                    keyboard_controller.press(key)
                    time.sleep(delay)
                    keyboard_controller.release(key)
                elif click_type == 1:
                    keyboard_controller.press(key)
                elif click_type == 2:
                    keyboard_controller.release(key)
            except Exception as e:
                print("Error sending keys:", e)
    # Interruptible sleep
    def interruptible_sleep(self, duration):
        duration = max(0.01, duration)
        end_time = time.perf_counter() + duration
        while time.perf_counter() < end_time:
            if not self.macro_running:
                break  # Interrupted

            remaining = end_time - time.perf_counter()
            time.sleep(min(0.01, remaining))

    # Get values
    def get_areas(self, area_key):
        # Apply Scale Factor
        scale = self._get_scale_factor()
        area_data = self.bar_areas.get(area_key)
        if (isinstance(area_data, dict) and area_data.get("width", 0) > 0 and area_data.get("height", 0) > 0):
            left   = area_data["x"]
            top    = area_data["y"]
            right  = area_data["x"] + area_data["width"]
            bottom = area_data["y"] + area_data["height"]
            width  = area_data["width"]
            height = area_data["height"]
        else:
            left, top, right, bottom = self._get_default_areas(area_key)
            width  = right - left
            height = bottom - top
        left2   = int(left * scale * self.SCREEN_WIDTH)
        top2    = int(top * scale * self.SCREEN_HEIGHT)
        right2  = int(right * scale * self.SCREEN_WIDTH)
        bottom2 = int(bottom * scale * self.SCREEN_HEIGHT)
        width2  = int(width * scale * self.SCREEN_WIDTH)
        height2 = int(height * scale * self.SCREEN_HEIGHT)
        return left2, top2, right2, bottom2, width2, height2

    def _get_default_areas(self, area):
        """Return (left, top, right, bottom) in physical pixels using AREA_CONFIG defaults."""
        cfg = AREA_CONFIG.get(area)
        if cfg:
            d = cfg["default"]
            left   = int(self.SCREEN_WIDTH  * d["x"])
            top    = int(self.SCREEN_HEIGHT * d["y"])
            right  = int(self.SCREEN_WIDTH  * (d["x"] + d["width"]))
            bottom = int(self.SCREEN_HEIGHT * (d["y"] + d["height"]))
        else:
            left, top, right, bottom = 0, 0, self.SCREEN_WIDTH, self.SCREEN_HEIGHT
        return left, top, right, bottom

    def _get_var_number(self, key, default, cast=float):
        """Returns a key from the GUI with Exception handling"""
        try:
            value = self.vars.get(key)
            if value is None:
                # Compatibility mapping for 1600plus key differences
                if key == "perfect_cast_timing_1600_plus":
                    value = self.vars.get("perfect_cast_timing_1600plus")
                if value is None:
                    return default

            if isinstance(value, str):
                value = value.strip()
                if value == "":
                    return default

            return cast(value)

        except Exception:
            return default

    # Detection
    def _hex_to_bgr(self, hex_color):
        "Convert hex color to BGR tuple for OpenCV."
        if hex_color is None or hex_color.lower() in ["none", "# None", ""]:
            return None

        hex_color = hex_color.lstrip('# ')
        if len(hex_color) == 6:
            try:
                r = int(hex_color[0:2], 16)
                g = int(hex_color[2:4], 16)
                b = int(hex_color[4:6], 16)
                return (b, g, r)  # Bgr Format For Opencv

            except ValueError:
                return None

        return None

    def capture_single_frame(self):
        """
        Capture a single full-screen frame without touching self.macro_running.
        Used by debug screenshots, eyedropper freeze, and Discord screenshot logging.
        """
        if sys.platform == "darwin":
            image = Quartz.CGWindowListCreateImage(
                Quartz.CGRectInfinite,
                Quartz.kCGWindowListOptionOnScreenOnly,
                Quartz.kCGNullWindowID,
                Quartz.kCGWindowImageDefault
            )
            if image is None:
                return None
            return cgimage_to_srgb_numpy(image)
        else:
            scale = self._get_scale_factor()
            with MSS() as sct:
                monitor = {
                    "top": 0,
                    "left": 0,
                    "width": int(SCREEN_WIDTH * scale),
                    "height": int(SCREEN_HEIGHT * scale),
                }
                return np.asarray(sct.grab(monitor))[:, :, :3]

    def capture_loop_mss(self):
        """Continuous capture loop for the macro. Assumes self.macro_running is already True."""
        if not self.macro_running:
            return

        self.capture_id = 0
        scale = self._get_scale_factor()
        with MSS() as sct:
            monitor = {
                "top": 0,
                "left": 0,
                "width": int(SCREEN_WIDTH * scale),
                "height": int(SCREEN_HEIGHT * scale),
            }
            while self.macro_running:
                self.capture_frame = np.asarray(sct.grab(monitor))[:, :, :3]
                self.capture_id += 1
                time.sleep(self.scan_delay)

    def capture_loop_quartz(self):
        """Continuous capture loop for the macro (macOS). Assumes self.macro_running is already True."""
        if not self.macro_running:
            return

        self.capture_id = 0
        while self.macro_running:
            if sys.platform == "darwin":
                image = Quartz.CGWindowListCreateImage(
                    Quartz.CGRectInfinite,
                    Quartz.kCGWindowListOptionOnScreenOnly,
                    Quartz.kCGNullWindowID,
                    Quartz.kCGWindowImageDefault
                )
            else:
                image = None
            if image is None:
                continue

            self.capture_frame = cgimage_to_srgb_numpy(image)
            self.capture_id += 1
            time.sleep(self.scan_delay)

    def pixel_search(self, frame, hex, tolerance, mode=0):
        """
        Searches for the first or last pixel based on mode.
        Mode 0: First pixel; Mode 1: Last pixel
        """
        if frame is None or frame.size == 0:
            return None, None

        if mode not in (0, 1):
            raise RuntimeError("Invalid detection mode")

        # Convert Tolerance To Int First, Handling String Inputs
        try:
            tolerance = int(tolerance)
        except (ValueError, TypeError):
            tolerance = 0  # or some default value
        # Failsafe: None Hex
        if hex is None:
            return None, None
        
        try:
            tolerance = int(np.clip(tolerance, 0, 255))
            b, g, r = self._hex_to_bgr(hex)
            target = np.array([b, g, r], dtype=np.int32)
            frame_i = frame.astype(np.int32)
            diff = frame_i - target
            mask = np.sqrt(np.sum(diff ** 2, axis=-1)) <= tolerance
            coords = np.argwhere(mask)
            if coords.size > 0:
                if mode == 0:
                    y, x = coords[0]
                else:
                    y, x = coords[-1]
                return int(x), int(y)
        except:
            return None, None

        return None, None

    def _calculate_speed_and_predict(self, white_positions, timestamps):
        """
        Calculate white pixel movement speed using linear regression on recent
        positions for smooth, stable velocity estimation.
        Returns velocity /second (positive = moving down, negative = up),
        or None if insufficient data.
        """
        if len(white_positions) < 2:
            return None

        n = len(white_positions)
        y_values = [pos[1] for pos in white_positions]
        time_values = [t - timestamps[0] for t in timestamps]
        mean_t = sum(time_values) / n
        mean_y = sum(y_values) / n
        numerator = sum(t * y for t, y in zip(time_values, y_values)) - n * mean_t * mean_y
        denominator = sum(t * t for t in time_values) - n * mean_t * mean_t
        if abs(denominator) < 0.0001:
            return None

        return numerator / denominator

    # Utility Functions
    def test_logging(self):
        logging_mode = self.vars["logging_mode"].capitalize()
        self.send_logging(f"**{logging_mode} is working**", "Macro Stopped")

    def send_logging(self, text, loop_count, catch_rate=-1):
        logging_mode = self.vars["logging_mode"].lower()
        if logging_mode == "disabled":
            self.set_status("⚠ Logging is disabled.")
            return

        webhook_url = None
        if logging_mode != "file":
            webhook_url = self.vars["logging_url"].strip()
            if not webhook_url.startswith("https://discord.com/api/webhooks/"):
                self.set_status("Error: Invalid webhook URL.")
                return

        self.set_status("Sending log...")
        if logging_mode == "screenshot":
            thread = threading.Thread(
                target=self._discord_screenshot_worker,
                args=(webhook_url, f"{text}\n", loop_count, catch_rate),
                daemon=True
            )
        else:
            thread = threading.Thread(
                target=self._discord_text_worker,
                args=(webhook_url, f"{text}\n", loop_count, catch_rate),
                daemon=True
            )
        thread.start()
        thread.join()  # Wait for Discord/file log to finish before continuing

    def _discord_text_worker(self, webhook_url, message_prefix, loop_count, catch_rate):
        """Worker function to send text webhook."""
        logging_name = self.vars["logging_name"]
        try:
            if catch_rate == -1:
                catch_rate = "N/A"
            payload = {
                'content': f'{message_prefix}🎣 Cycle completed\n🔄 {loop_count}\nCatch rate: {catch_rate}\n🕐 {time.strftime("%Y-%m-%d %H:%M:%S")}',
                'username': logging_name,
                'embeds': [{
                    'description': f'{loop_count}',
                    'color': 0x5865F2,
                    'timestamp': time.strftime("%Y-%m-%dT%H:%M:%S")
                }]
            }
            response = requests.post(webhook_url, json=payload, timeout=10)
            if response.status_code == 200 or response.status_code == 204:
                self.set_status(f"Discord text sent ({loop_count})")
            else:
                self.set_status(f"Error: Discord text failed: {response.status_code}")
        except Exception as e:
            self.set_status(f"Error sending Discord text: {e}")

    def _discord_screenshot_worker(self, webhook_url, message_prefix, loop_count, catch_rate):
        logging_name = self.vars["logging_name"]

        try:
            screenshot = self.capture_single_frame()

            if screenshot is None:
                self.set_status("Error: failed to capture screenshot for Discord")
                return

            # Convert BGR/BGRA → RGB without OpenCV
            if screenshot.shape[2] == 4:
                rgb_screenshot = screenshot[:, :, [2, 1, 0]]
            else:
                rgb_screenshot = screenshot[:, :, ::-1]

            img = Image.fromarray(rgb_screenshot, "RGB")

            # Encode PNG directly into memory
            buffer = io.BytesIO()
            img.save(buffer, format="PNG")
            buffer.seek(0)

            files = {
                "file": ("screenshot.png", buffer, "image/png")
            }

            if catch_rate == -1:
                catch_rate = "N/A"

            payload = {
                "content": (
                    f"{message_prefix}🎣 **Cycle completed**\n"
                    f"🔄 {loop_count}\n"
                    f"🎯 Catch rate: {catch_rate}\n"
                    f'🕐 {time.strftime("%Y-%m-%d %H:%M:%S")}'
                ),
                "username": logging_name
            }

            response = requests.post(
                webhook_url,
                data=payload,
                files=files,
                timeout=10
            )

            if response.status_code in (200, 204):
                self.set_status(f"Discord screenshot sent ({loop_count})")
            else:
                self.set_status(
                    f"Error: Discord screenshot failed: {response.status_code}"
                )

        except Exception as e:
            self.set_status(f"Error sending Discord screenshot: {e}")

    def start_fishing(self):
        # 1. Core Config & Modes
        scale = self._get_scale_factor()
        self.macro_running = True
        
        casting_mode = self.vars["casting_mode"].lower()
        shake_mode = self.vars["shake_mode"].lower()
        logging_mode = self.vars["logging_mode"].lower()
        click_after_minigame = self.vars["click_after_minigame"].lower()
        logging_cycle = int(self.vars["logging_cycle"])
        
        # 2. Hotkey & Inventory Slots
        bag_slot = str(self.vars["bag_slot"])
        rod_slot = str(self.vars["rod_slot"])
        
        # 3. Delays & Timings
        select_rod_duration = float(self.vars["select_rod_duration"])
        delay_before_casting = float(self._get_var_number("delay_before_casting", 0.5, float))
        delay_after_casting = float(self._get_var_number("cast_delay", 1.0, float))
        
        # 4. Screen Regions & Coordinates
        shake_left, shake_top, shake_right, shake_bottom, shake_w, shake_h = self.get_areas("shake")
        fish_left, fish_top, fish_right, fish_bottom, _, fish_height = self.get_areas("fish")
        friend_left_s, friend_top_s, friend_right_s, friend_bottom_s, _, _ = self.get_areas("friend")
        
        shake_x = shake_left + (shake_w // 2)
        shake_y = shake_top + (shake_h // 2)
        
        # 5. Features & Overlay Settings
        shake_failsafe = int(self.vars["shake_failsafe"])
        friend_color = self.vars["friends_color"]
        friend_tolerance = int(self.vars["friends_tolerance"])
        auto_refresh = self.vars["auto_refresh"]
        fish_overlay = self.vars["fish_overlay"]
        
        # 7. Internal Tracking State
        self.scan_delay = 0.1
        self.current_cycle = 0
        current_time = None
        
        # Catch Metrics (0 = success, 1 = failed, 2 = N/A initial state)
        self.catch_success = 2
        self.catch_rate = 0.0
        successful_catches = 0
        if fish_overlay == "on":
            # Position the overlay just above or below the fish bar so it does
            # not cover the actual minigame.  show() expects (left, top, width,
            # height) in physical pixels — NOT right/bottom.
            fish_center = int((fish_top + fish_bottom) / 2)
            if fish_center > HALF_HEIGHT:
                fish_top_overlay = fish_top - fish_height - fish_height
            else:
                fish_top_overlay = fish_top + fish_height + fish_height
            overlay_width = fish_right - fish_left
            overlay_height = fish_height
            self.fish_overlay.show(
                fish_left,
                fish_top_overlay,
                overlay_width,
                overlay_height,
            )
        # Main Loop (With bug reports)
        try:
            while self.macro_running:
                self.set_status("Resetting statistics")
                self.capture_id = 0
                if auto_refresh == "on":
                    time.sleep(delay_before_casting)
                    self._send_key(bag_slot)
                    self.interruptible_sleep(select_rod_duration)
                    self._send_key(rod_slot)
                    self.interruptible_sleep(delay_after_casting / 2)
                self.current_cycle = self.current_cycle + 1
                # Cast
                self.set_status("Casting")
                time.sleep(delay_before_casting)
                if casting_mode == "perfect":
                    self._execute_cast_perfect()
                else:
                    self._execute_cast_normal()
                time.sleep(delay_after_casting)
                # Shake
                self.set_status("Shaking")
                self.scan_delay = float(self.vars["shake_scan_delay"])
                for attempts in range(shake_failsafe):
                    if self.capture_frame is None:
                        attempts = attempts - 1
                        continue
                    friend_img = self.capture_frame[friend_top_s:friend_bottom_s, friend_left_s:friend_right_s]
                    friend_x, friend_y = self.pixel_search(friend_img, friend_color, friend_tolerance)
                    if friend_x is None or friend_y is None:
                        break

                    if self.macro_running == False:
                        break
                    elif shake_mode == "navigation":
                        keyboard_controller.press(Key.enter)
                        time.sleep(0.01)
                        keyboard_controller.release(Key.enter)
                    else:
                        self._execute_shake_click()
                    time.sleep(self.scan_delay)
                # Minigame — sets self.catch_success = 0 at start; flips to 1 if fish ever leaves the bar
                self.set_status("Playing Bar Minigame")
                self._enter_minigame()
                if click_after_minigame == "on":
                    time.sleep(select_rod_duration)
                    self._click_at(shake_x, shake_y)
                # Update catch rate after the minigame finishes
                if self.catch_success == 0:
                    successful_catches += 1
                self.catch_rate = successful_catches / self.current_cycle
                catch_rate_percentage = int(self.catch_rate * 100)
                if logging_mode != "disabled":
                    if self.current_cycle == logging_cycle:
                        self.send_logging("**Cycle Checkpoint**", f"Cycle #{self.current_cycle}", catch_rate_percentage)
                    logging_cycle = logging_cycle + self.current_cycle
            return
        except Exception as e:
            time.sleep(0.2)
            full_error = traceback.format_exc()
            error_lines = full_error.splitlines()
            error_line = error_lines[1].split("line ")
            error_line = error_line[1].split(",")
            error_line = error_line[0]
            self.message_box_javascript(f"An error at line {error_line} occured. Please copy the error and report the bug:\\n{e}\\nWould you like to copy the full crash log to your clipboard?", full_error)
            if IS_COMPILED == False:
                print(full_error)
            self.macro_running = False
            self.stop_macro(f"Error at line {error_line}: {e}")
    def _execute_cast_perfect(self):
        # Areas
        shake_left, shake_top, shake_right, shake_bottom, _, shake_height = self.get_areas("shake")
        # Colors
        white_cast_color = self.vars["white_cast_color"]
        green_cast_color = self.vars["green_cast_color"]
        # Tolerance
        white_cast_tolerance = int(self.vars["white_cast_tolerance"])
        green_cast_tolerance = int(self.vars["green_cast_tolerance"])
        # Perfect Cast Settings
        perfect_cast_method = self.vars["perfect_cast_method"].lower()
        fall_scan_timeout = float(self.vars["fall_scan_timeout"])
        self.scan_delay = float(self.vars["cast_scan_delay"])
        # Last Values (Failsafe)
        last_capture_id = 0
        is_initial_run = True
        is_green_tracking = False
        green_detected = False
        start_time = time.time()
        last_time = time.time()
        self.hold_mouse()
        green_padding = 50
        released = False
        # Simple Method Variables
        speed_samples = []
        white_positions = []
        white_timestamps = []
        max_speed_samples = 20
        release_delay = float(self.vars["release_delay_simple"])
        perfect_threshold = float(self.vars["perfect_threshold"])  # Hardcoded value - setting removed in later versions
        release_timing = max(-50.0, min(50.0, release_delay))
        # Velocity Method Variables
        if perfect_cast_method == "velocity":
            white_positions = []
            white_timestamps = []
            MAX_VELOCITY_SAMPLES = 10
            last_time_to_impact = None
            # Get Screen Resolution For Scaling
            scaling_factor = 1920 / SCREEN_WIDTH
        if perfect_cast_method == "prediction":
            highest_cast_percentage = 100
            highest_cast_percentage_updated = False
        # Initialize Tracking Variables
        green_abs_top = 0
        green_abs_left = 0
        green_abs_right = 0
        green_abs_bottom = 0
        reached_bottom_5_percent = True
        last_fill_percentage = None
        last_frame_time = None
        # Loop
        while self.macro_running:
            # Check If Dxcam Is Available
            if dxcam is not None:
                self.capture_frame = self.camera.get_latest_frame()
                self.capture_id = last_capture_id + 1
            # Get Image From Self.Capture_Frame
            if self.capture_id == last_capture_id:
                time.sleep(self.scan_delay)
                continue

            if self.capture_frame is None:
                time.sleep(self.scan_delay)
                continue

            # Scan Time Calculations
            current_time = time.time()
            elapsed_time = current_time - start_time
            time_delta = current_time - last_time
            if elapsed_time >= fall_scan_timeout:
                self.release_mouse()
                released = True
                break

            # Check If Macro Stopped During Perfect Cast
            if not self.macro_running:
                self.release_mouse()
                released = True
                break

            # Status Overlay
            self.status_overlay.set_line(1, "Green: ", f"Undefined")
            self.status_overlay.set_line(2, "White: ", f"Undefined")

            # Scanning From Shake_Left, Shake_Top To Shake_Right, Shake_Bottom
            shake_img = self.capture_frame[shake_top:shake_bottom, shake_left:shake_right]
            # Green Detection
            if is_green_tracking:
                # Track In Subregion Around Last Known Green Position
                green_area_top = max(0, green_abs_top - green_padding)
                green_area_bottom = min(shake_img.shape[0], green_abs_top + green_padding)
                green_area_left = max(0, green_abs_left - green_padding)
                green_area_right = min(shake_img.shape[1], green_abs_right + green_padding)
                green_area = shake_img[green_area_top:green_area_bottom, green_area_left:green_area_right]
                g_left, g_top = self.pixel_search(green_area, green_cast_color, green_cast_tolerance)
                g_right, g_bottom = self.pixel_search(green_area, green_cast_color, green_cast_tolerance, 1)
                if None not in (g_left, g_top, g_right, g_bottom):
                    # Convert From Green_Area Coordinates To Shake_Img Coordinates
                    green_abs_left = g_left + green_area_left
                    green_abs_top = g_top + green_area_top
                    green_abs_right = g_right + green_area_left
                    green_abs_bottom = g_bottom + green_area_top
                    green_detected = True
                else:
                    green_detected = False
                    is_green_tracking = False
                    if perfect_cast_method == "simple":
                        speed_samples.clear()
                    else:
                        white_positions.clear()
                        white_timestamps.clear()
                    self.status_overlay.set_line(1, "Green: ", f"None (Full Scan)")
                    continue  # Skip this frame, try full scan next frame

            if not is_green_tracking:
                # Full Scan For Green
                g_left, g_top = self.pixel_search(shake_img, green_cast_color, green_cast_tolerance)
                g_right, g_bottom = self.pixel_search(shake_img, green_cast_color, green_cast_tolerance, 1)
                if None not in (g_left, g_top, g_right, g_bottom):
                    green_abs_left = g_left
                    green_abs_top = g_top
                    green_abs_right = g_right
                    green_abs_bottom = g_bottom
                    green_detected = True
                    is_green_tracking = True
                else:
                    self.status_overlay.set_line(1, "Green: ", f"None (Skipped)")
                    continue  # No green found, try again
            # Show Status For Green
            self.status_overlay.set_line(1, "Green: ", f"{green_abs_left}, {green_abs_top}")

            # White Detection
            # Search vertically below the center of the green bar.
            green_center_x = (green_abs_left + green_abs_right) // 2

            # Keep the coordinate inside shake_img.
            green_center_x = max(
                0,
                min(green_center_x, shake_img.shape[1] - 1)
            )

            # Comet-style vertical scan:
            # start at the green bar and scan all the way to the
            # bottom of the captured region.
            scan_start_y = max(0, green_abs_top)
            scan_end_y = shake_img.shape[0]

            white_column = shake_img[
                scan_start_y:scan_end_y,
                green_center_x:green_center_x + 1,
                :
            ]

            # Per-channel tolerance:
            # a pixel matches when every B/G/R channel is within
            # white_cast_tolerance of the target color.
            white_b, white_g, white_r = self._hex_to_bgr(white_cast_color)

            white_target = np.array(
                [white_b, white_g, white_r],
                dtype=np.int16
            )

            white_column_i = white_column.astype(np.int16)

            white_diff = np.abs(
                white_column_i - white_target
            )

            white_mask = (
                np.max(white_diff, axis=2)
                <= white_cast_tolerance
            )

            # Get every matching Y position on the center column.
            white_rows = np.flatnonzero(white_mask[:, 0])

            if white_rows.size == 0:
                self.status_overlay.set_line(2, "White: ", f"None (Skipped)")
                continue

            # First matching pixel = top of the white target.
            white_abs_top = scan_start_y + int(white_rows[0])

            # Last matching pixel = bottom of the white target.
            # Keeping this allows Solar's existing Simple and Prediction
            # methods to continue using total_distance.
            white_abs_bottom = scan_start_y + int(white_rows[-1])

            # Existing Solar distance calculations.
            total_distance = white_abs_bottom - green_abs_top
            current_distance = white_abs_top - green_abs_top

            if total_distance <= 0:
                self.status_overlay.set_line(
                    2,
                    "White: ",
                    f"{total_distance} (Invalid)"
                )
                continue

            self.status_overlay.set_line(
                2,
                "White: ",
                f"{green_center_x}, {white_abs_top}"
            )

            # Release Logic Based On Selected Method
            # Velocity Tracking
            white_positions.append((0, white_abs_top))  # x is irrelevant; track Y only
            white_timestamps.append(current_time)
            if len(white_positions) > MAX_VELOCITY_SAMPLES:
                white_positions.pop(0)
                white_timestamps.pop(0)
            # Local_Distance: Pixels Remaining Until White Reaches Green
            local_distance = current_distance  # white_abs_top - green_abs_top; positive = white below green
            # Velocity-Band Predictive Release
            if len(white_positions) >= 3:
                velocity_y = self._calculate_speed_and_predict(white_positions, white_timestamps)
                min_speed = 5 * scaling_factor
                if velocity_y is not None and abs(velocity_y) > min_speed:
                    white_above_green = white_abs_top < green_abs_top
                    moving_toward_green = (white_above_green and velocity_y > 0) or (not white_above_green and velocity_y < 0)
                    if moving_toward_green and local_distance > 0:
                        time_to_impact = local_distance / abs(velocity_y)
                        self.status_overlay.set_line(3, "Time To Impact: ", round(time_to_impact, 2))
                        # Bounce/Miss Detection: If Tti Suddenly Grows When Very Close, We Passed Green
                        bounce_threshold = 40 * scaling_factor
                        if last_time_to_impact is not None and local_distance < bounce_threshold:
                            if time_to_impact > last_time_to_impact * 1.3:
                                self.release_mouse()
                                released = True
                        if not released:
                            # Velocity-Band Reaction Delays (Tuned At 1440P)
                            v = abs(velocity_y)
                            if v < 700 * scaling_factor:
                                reaction_delay = 0.060
                                timing_key = "perfect_cast_timing_700"
                            elif v < 800 * scaling_factor:
                                reaction_delay = 0.058
                                timing_key = "perfect_cast_timing_800"
                            elif v < 900 * scaling_factor:
                                reaction_delay = 0.057
                                timing_key = "perfect_cast_timing_900"
                            elif v < 1000 * scaling_factor:
                                reaction_delay = 0.056
                                timing_key = "perfect_cast_timing_1000"
                            elif v < 1100 * scaling_factor:
                                reaction_delay = 0.055
                                timing_key = "perfect_cast_timing_1100"
                            elif v < 1200 * scaling_factor:
                                reaction_delay = 0.050
                                timing_key = "perfect_cast_timing_1200"
                            elif v < 1300 * scaling_factor:
                                reaction_delay = 0.048
                                timing_key = "perfect_cast_timing_1300"
                            elif v < 1400 * scaling_factor:
                                reaction_delay = 0.047
                                timing_key = "perfect_cast_timing_1400"
                            elif v < 1500 * scaling_factor:
                                reaction_delay = 0.046
                                timing_key = "perfect_cast_timing_1500"
                            elif v < 1600 * scaling_factor:
                                reaction_delay = 0.050
                                timing_key = "perfect_cast_timing_1600"
                            else:
                                reaction_delay = 0.049
                                timing_key = "perfect_cast_timing_1600_plus"
                            timing_adjustment_ms = self._get_var_number(timing_key, 0, int)
                            reaction_delay += timing_adjustment_ms * 0.001
                            if time_to_impact <= reaction_delay:
                                self.release_mouse()
                                released = True
                        last_time_to_impact = time_to_impact
            # Slow-Speed / Emergency Distance Fallbacks
            if not released:
                slow_threshold = total_distance * 0.05  # within 5% of green
                emergency_threshold = total_distance * 0.025
                self.status_overlay.set_line(3, "Local Distance: ", local_distance)
                if local_distance <= emergency_threshold:
                    self.release_mouse()
                    released = True
                elif local_distance <= slow_threshold and len(white_positions) >= 3:
                    # Confirm Approach: Latest Distance < Oldest Distance
                    recent_dists = [p[1] - green_abs_top for p in white_positions[-3:]]
                    if recent_dists[-1] < recent_dists[0]:
                        self.release_mouse()
                        released = True
            if released:
                break
            if time.time() - start_time > fall_scan_timeout:
                break

            # Cleanup
            time.sleep(self.scan_delay)
            last_capture_id = self.capture_id
            is_initial_run = False
            last_time = current_time
        # Final Cleanup
        self.release_mouse()
        self._fish_overlay_cast_bounds = None
        return

    def _execute_cast_normal(self):
        if self.macro_running == False:
            return
        cast_duration = float(self._get_var_number("cast_duration", 0.5, float))
        self.hold_mouse(False)
        self.interruptible_sleep(cast_duration)
        self.release_mouse(False)
        return

    def _execute_shake_click(self):
        scale = self._get_scale_factor()
        shake_left, shake_top, shake_right, shake_bottom, _, _ = self.get_areas("shake")
        shake_color = self.vars["shake_color"]
        shake_tolerance = self.vars["shake_tolerance"]
        shake_img = self.capture_frame[shake_top:shake_bottom, shake_left:shake_right]
        shake_x, shake_y = self.pixel_search(shake_img, shake_color, shake_tolerance)
        try:
            shake_x_screen = int((shake_x / scale) + shake_left)
            shake_y_screen = int((shake_y / scale) + shake_top)
        except:
            shake_x_screen = None
            shake_y_screen = None
        self._click_at(shake_x_screen, shake_y_screen)
        return
    def _enter_minigame(self):
        # Helper Functions
        mouse_down = False
        def hold_mouse(mouse_state=False):
            "Hold mouse. False for left click, True for right click."
            nonlocal mouse_down
            if not mouse_down:
                self.hold_mouse(mouse_state)
                mouse_down = True
        def release_mouse(mouse_state=False):
            "Release mouse. False for left click, True for right click."
            nonlocal mouse_down
            if mouse_down:
                self.release_mouse(mouse_state)
                mouse_down = False
        # Areas
        shake_left, shake_top, shake_right, shake_bottom, _, shake_height = self.get_areas("shake")
        fish_left, fish_top, fish_right, fish_bottom, fish_width, fish_height = self.get_areas("fish")
        friend_left, friend_top, friend_right, friend_bottom, _, _ = self.get_areas("friend")
        # Area Calculations
        note_height = fish_bottom - shake_top
        shake_x = int((shake_left + shake_right) / 2)
        shake_y = int((shake_top + shake_bottom) / 2)
        fish_overlay = self.vars["fish_overlay"]
        if fish_overlay == "on":
            # Position the overlay just above or below the fish bar so it does
            # not cover the actual minigame.  show() expects (left, top, width,
            # height) in physical pixels — NOT right/bottom.
            fish_center = int((fish_top + fish_bottom) / 2)
            if fish_center > HALF_HEIGHT:
                fish_top_overlay = fish_top - fish_height - fish_height
            else:
                fish_top_overlay = fish_top + fish_height + fish_height
            overlay_width = fish_right - fish_left
            overlay_height = fish_height
            self.fish_overlay.show(
                fish_left,
                fish_top_overlay,
                overlay_width,
                overlay_height,
            )
        # Colors
        left_color = self.vars["left_color"]
        right_color = self.vars["right_color"]
        arrow_color = self.vars["arrow_color"]
        fish_color = self.vars["fish_color"]
        friends_color = self.vars["friends_color"]
        # Tolerance
        try:
            left_tolerance = int(self.vars["left_tolerance"])
            right_tolerance = int(self.vars["right_tolerance"])
            arrow_tolerance = int(self.vars["arrow_tolerance"])
            fish_tolerance = int(self.vars["fish_tolerance"])
            friends_tolerance = int(self.vars["friends_tolerance"])
        except:
            left_tolerance = 8
            right_tolerance = 8
            arrow_tolerance = 8
            fish_tolerance = 4
            friends_tolerance = 5
        # Minigame Settings
        scale = get_scale_factor()
        bag_slot = str(self.vars["bag_slot"])
        bag_spam = self.vars["bag_spam"]
        lock_cursor = self.vars["lock_cursor"]
        bar_ratio_from_side = float(self.vars["bar_ratio_from_side"])
        restart_delay = float(self.vars["restart_delay"])
        self.scan_delay = float(self.vars["minigame_scan_delay"])
        kp = self._get_var_number("kp", 0.45)
        kd = self._get_var_number("kd", 0.35)
        # Last values (failsafe)
        is_initial_run = True
        bar_detected = False
        bag_spam_cycle = 0
        fish_size = 10
        note_x = 0
        note_y_ratio = 0
        bar_size = 0
        bar_center = 0
        error = 0
        last_capture_id = 0
        last_fish_x = 0
        last_left_x = 0
        last_right_x = 0
        last_bar_center = 0
        last_bar_size = 0
        last_error = 0
        color_check_bar_velocity = 0.0
        color_check_target_velocity = 0.0
        self.catch_success = 0
        last_time = time.perf_counter()
        # Loop
        while self.macro_running:
            # Get image from self.capture_frame
            if self.capture_id == last_capture_id:
                time.sleep(self.scan_delay)
                continue
            if self.capture_frame is None:
                time.sleep(self.scan_delay)
                continue
            else:
                shake_img = self.capture_frame[shake_top:fish_bottom, fish_left:fish_right]
                fish_img = self.capture_frame[fish_top:fish_bottom, fish_left:fish_right]
                friend_img = self.capture_frame[friend_top:friend_bottom, friend_left:friend_right]
            # Friend detection
            friend_x, friend_y = self.pixel_search(friend_img, friends_color, friends_tolerance)
            if friend_x is not None and friend_y is not None:
                time.sleep(restart_delay)
                return

            # Fish detection
            fish_x, fish_y = self.pixel_search(fish_img, fish_color, fish_tolerance)
            if fish_x is not None:
                fish_detected = True
            else:
                fish_detected = False
            # Color detection
            left_x, left_y = self.pixel_search(fish_img, left_color, left_tolerance)
            right_x, right_y = self.pixel_search(fish_img, right_color, right_tolerance, 1)
            if left_x == None:
                left_x, left_y = self.pixel_search(fish_img, right_color, right_tolerance)
            if right_x == None:
                right_x, right_y = self.pixel_search(fish_img, left_color, left_tolerance, 1)
            # print(f"Raw coordinates: {left_x}, {right_x}, {fish_x}")
            # Check if we should scan for arrows
            if left_x is not None and right_x is not None:
                bar_detected = True
                # print(f"Detection Source: Bar | Left: {left_x} | Right: {right_x}")
            else:
                # Try arrow
                bar_detected = False
                # Bars not found - scan for arrows
                arrow_x, arrow_y = self.pixel_search(fish_img, arrow_color, arrow_tolerance)
                if last_left_x is None or last_right_x is None:
                    last_left_x = 0
                    last_right_x = 0
                if last_left_x == 0 or last_right_x == 0:
                    if mouse_down == True:
                        last_left_x = arrow_x
                    else:
                        last_right_x = arrow_x
                if arrow_x is not None:
                    bar_detected = True
                    arrow_on_left_side = arrow_x - last_bar_center
                    dist_to_left = (arrow_x - last_left_x) if last_left_x is not None else fish_width
                    dist_to_right = (arrow_x - last_right_x) if last_right_x is not None else fish_width
                    proximity_threshold = int(last_bar_size / 4)
                    # Flip decision if wrong
                    if arrow_on_left_side:
                        if dist_to_right < dist_to_left and dist_to_right < proximity_threshold:
                            # Arrow is actually closer to RIGHT bar - we were wrong!
                            arrow_on_left_side = False  # Flip the decision
                    else:
                        if dist_to_left < dist_to_right and dist_to_left < proximity_threshold:
                            # Arrow is actually closer to LEFT bar - we were wrong!
                            arrow_on_left_side = True  # Flip the decision
                    if arrow_on_left_side:
                        left_x = arrow_x
                        right_x = last_right_x
                        if right_x is None or right_x == 0:
                            right_x = left_x + last_bar_size
                    else:
                        right_x = arrow_x
                        left_x = last_left_x
                        if left_x is None or left_x == 0:
                            left_x = right_x - last_bar_size
                else:
                    # Use Cache
                    bar_detected = False
            try:
                bar_center = int((left_x + right_x) / 2)
                bar_size = right_x - left_x
            except:
                bar_center = 0
                bar_size = 0
            # print(f"bar_detected: {bar_detected}")
            # print(f"left_x: {left_x}, right_x: {right_x}")
            # print(f"bar_center: {bar_center}, bar_size: {bar_size}")
            # Bag Spam & Lock Cursor
            bag_spam_cycle += 1
            if bag_spam_cycle == 5:
                bag_spam_cycle = 0
                if bag_spam == "on":
                    self._send_key(bag_slot)
                if lock_cursor == "on":
                    mouse_controller.position = (int(shake_x / scale), int(shake_y / scale))
            # Restore from Cache
            self.fish_overlay.clear()
            if bar_detected == False:
                left_x = last_left_x
                right_x = last_right_x
                bar_center = last_bar_center
                bar_size = last_bar_size
            if fish_detected == False:
                fish_x = last_fish_x
            # Edge Boundary
            if bar_size is not None:
                boundary = bar_size * bar_ratio_from_side
                left_boundary = boundary
                right_boundary = fish_right - boundary - fish_left
            else:
                left_boundary = None
                right_boundary = fish_width
            # print("Boundary: ", left_boundary, right_boundary, " Fish: ", fish_x)
            # print("Last Cache: ", bar_center - last_bar_center)
            # Fish Overlay
            if fish_overlay == "on":
                self.fish_overlay.draw_box(
                    bar_center=bar_center, box_size=bar_size,
                    color="green", canvas_offset=0,
                    show_bar_center=True
                )
                if left_boundary is not None:
                    self.fish_overlay.draw_box(
                        bar_center=left_boundary, box_size=15,
                        color="lightblue", canvas_offset=0
                    )
                if right_boundary is not None:
                    self.fish_overlay.draw_box(
                        bar_center=right_boundary, box_size=15,
                        color="lightblue", canvas_offset=0
                    )
                if fish_x is not None:
                    self.fish_overlay.draw_box(
                        bar_center=fish_x, box_size=fish_size,
                        color="red", canvas_offset=0
                    )
            # PD controller
            current_time = time.perf_counter()
            time_delta = current_time - last_time
            last_time = current_time
            if fish_x is not None:
                error = fish_x - bar_center
            else:
                error = 0
                fish_x = 0
            if (fish_x < left_boundary):
                control_signal = -30
            elif (fish_x > right_boundary):
                control_signal = 30
            else:
                # Normal: Traditional PD controller
                if is_initial_run == True:
                    control_signal = 0
                    last_error = error
                else:
                    if time_delta < 0.001:
                        time_delta = 0.001
                    p_term = error * kp
                    d_term = ((error - last_error) / time_delta) * kd
                    control_signal = p_term + d_term
                    # print("error - last_error: ", error - last_error)
                    # print("time_delta: ", time_delta)
                    # print("p_term: ", p_term)
                    # print("d_term: ", d_term)
                    last_error = error
            # Mouse state
            # print(f"error: {error}")
            # print(f"control_signal: {control_signal}")
            if control_signal > 0:
                hold_mouse()
            else:
                release_mouse()
            # Update Cache
            if bar_detected == True:
                last_left_x = left_x
                last_right_x = right_x
                last_bar_center = bar_center
                last_bar_size = bar_size
            if fish_detected == True:
                if not fish_x == note_x:
                    last_fish_x = fish_x
            try:
                last_arrow_x = arrow_x
            except:
                pass
            # Cleanup
            is_initial_run = False
            last_capture_id = self.capture_id
            time.sleep(self.scan_delay)
        return

    def stop_macro(self, text="Macro Stopped"):
        self.macro_running = False
        self.fish_overlay.hide()

        if (
            self.macro_thread
            and self.macro_thread.is_alive()
            and self.macro_thread is not threading.current_thread()
        ):
            self.macro_thread.join()

        if (
            self.capture_thread
            and self.capture_thread.is_alive()
            and self.capture_thread is not threading.current_thread()
        ):
            self.capture_thread.join()

        if text:
            self.set_status(text)

        try:
            window.show()
        except Exception:
            pass
try:
    with open(os.path.join(UI_PATH, "index.html"), "r", encoding="utf-8-sig") as file:
        lines = file.readline().strip()
    with open(os.path.join(UI_PATH, "style.css"), "r", encoding="utf-8-sig") as file:
        lines = file.readline().strip()
    with open(os.path.join(UI_PATH, "app.js"), "r", encoding="utf-8-sig") as file:
        lines = file.readline().strip()
except FileNotFoundError:
    open_folder = messagebox.askyesno("Missing Files", """Your installation is missing the configs, images and UI folder.
    Please report this bug in the Discord Server.\n
    Do you want to open the configs folder?""")
    if open_folder == True:
        open_base_folder()
    sys.exit(0)
api = Api()
window = webview.create_window(
    f"Solar Fishing V{APP_VERSION}",
    os.path.join(UI_PATH, "index.html"),
    js_api=api,
    width=1000,
    height=700
)
webview.start(gui="edgechromium")
