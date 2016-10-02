import os
import json
import shutil
import base64
import subprocess
from io import BytesIO
from PIL import Image
from PIL.PngImagePlugin import PngImageFile

# Paths to cli tools
# Fill your values in
EXE_MAGICK = "C:/buckle2000/software/ImageMagick/convert.exe"
EXE_ASEPRITE = r"C:\buckle2000\software\Aseprite\Aseprite.exe"

# path constants
PATH_MATERIAL = "raw-assets/"  # input (raw material) directory
PATH_ASSETS = "assets/"  # output directory
PATH_ASSETS_MAP = PATH_ASSETS + "map/"
PATH_ASSETS_IMAGE = PATH_ASSETS + "image/"


def assert_not_exist(path):
    # assert file does not exist
    if os.path.exists(path):
        raise FileExistsError("File %s already exists" % path)


def create_dir(path):
    if not os.path.exists(path):
        os.mkdir(path)


def run():
    shutil.rmtree(PATH_ASSETS_IMAGE, True)
    create_dir(PATH_ASSETS_IMAGE)
    for filename in os.listdir(PATH_MATERIAL):
        # ignore if file name starts with -
        if filename.startswith('-'):
            continue
        root, ext = os.path.splitext(filename)
        ext = ext.lower()
        file = PATH_MATERIAL + filename
        if ext == ".xcf":  # Gimp image
            dst = PATH_ASSETS_IMAGE + root + ".png"
            assert_not_exist(dst)
            subprocess.run((EXE_MAGICK, file, dst))
        elif ext == ".png":  # Normal png file
            dst = PATH_ASSETS_IMAGE + root + ".png"
            if not os.path.exists(dst):
                shutil.copy(file, dst)
        elif ext == ".ase" or ext == ".aseprite":
            dst = PATH_ASSETS_IMAGE + root + ".png"
            sheet_data = PATH_ASSETS_IMAGE + root + ".json"
            assert_not_exist(dst)
            subprocess.run((EXE_ASEPRITE, '-b', file,
                            "--sheet", dst, "--data", sheet_data, "--list-layers", "--list-tags", "--format", "json-array"))
        else:
            continue
        print(filename, 'exported')


import traceback
if __name__ == '__main__':
    try:
        run()
    except Exception as e:
        traceback.print_exc()
        input()  # wait
