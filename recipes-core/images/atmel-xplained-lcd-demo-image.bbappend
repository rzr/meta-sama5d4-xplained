#DESCRIPTION = "An image for SAMA5D3 Xplained with screen."
#LICENSE = "MIT"
#PR = "r1"

#require atmel-demo-image.inc

IMAGE_FEATURES += "splash"

IMAGE_INSTALL += "\
    packagegroup-base-usbhost \
    fb-test \
    tslib \
    tslib-conf \
    tslib-tests \
    tslib-calibrate \
    "


IMAGE_FEATURES += "splash package-management ssh-server-dropbear hwcodecs"

IMAGE_INSTALL += "packagegroup-base-3g  packagegroup-base-usbhost"

IMAGE_INSTALL += "screen rsync strace"

IMAGE_INSTALL += "i2c-tools"

DISTRO_FEATURES = "wayland"
DISTRO_FEATURES_remove = "x11"
IMAGE_INSTALL += "weston weston-init weston-examples"

IMAGE_INSTALL += "libdrm-tests libegl-mesa "
IMAGE_INSTALL += "libgl-mesa libgles1-mesa libgles2-mesa"
IMAGE_INSTALL += "libegl-gallium libgbm-gallium"
IMAGE_INSTALL += "libwayland-egl"
IMAGE_INSTALL += "qtwayland qtwayland-plugins"
IMAGE_INSTALL += "qtdeclarative-tools cinematicexperience"


IMAGE_INSTALL += "\
    qtbase-fonts \
    qtbase-plugins \
    qtbase-tools \
    qtdeclarative \
    qtdeclarative-plugins \
    qtdeclarative-tools \
    qtdeclarative-qmlplugins \
    qtmultimedia \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
    qtsvg \
    qtsvg-plugins \
    qtsensors \
    qtimageformats-plugins \
    qtsystems \
    qtsystems-tools \
    qtsystems-qmlplugins \
    qtscript \
"

IMAGE_INSTALL += " qtquick1 qtquick1-tools"
