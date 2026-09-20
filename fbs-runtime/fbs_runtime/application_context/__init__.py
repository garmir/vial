# small stand in for the fbs runtime, which is not packaged for nix.
# vial only uses the application context for build settings and resource
# paths, so that is all this provides.
import json
import os
from functools import cached_property

from PyQt5.QtWidgets import QApplication

# set by the package: the directory holding build_settings.json and the
# resource files
_share = os.environ.get("VIAL_SHARE_DIR", os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


class ApplicationContext:
    def __init__(self):
        # fbs creates the qt application up front, and vial builds widgets
        # right after making the context, so do the same here
        self.app

    @cached_property
    def build_settings(self):
        with open(os.path.join(_share, "build_settings.json")) as inf:
            return json.load(inf)

    @cached_property
    def app(self):
        return QApplication([])

    def get_resource(self, *parts):
        return os.path.join(_share, "resources", *parts)


def is_frozen():
    # never a frozen bundle here, vial runs from the installed source
    return False
