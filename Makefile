#! /usr/bin/make -f
# Author: Philippe Coval <philippe.coval@open.eurogiciel.org>
# ex: set tabstop=4 noexpandtab:

SHELL?=/bin/bash

branch?=dizzy
repo_branch?=${branch}
image?=atmel-xplained-lcd-demo-image

TOPDIR?=${CURDIR}

# TODO overide if installed elsewhere
sam_ba?=$(shell which sam-ba || echo /usr/local/opt/sam-ba_cdc_linux/sam-ba)
sam_ba_url?=http://www.atmel.com/dyn/resources/prod_documents/sam-ba_2.15.zip
sam_ba_file?=$(shell basename -- "${sam_ba_url}")
sam_ba_sum?=ad37112f31725bd405c4fcaa9c6a837408cecd55
console_dev?=/dev/ttyACM0
flash_dev?=/dev/ttyACM1

bsp?=atmel
board_vendor?=at91
board_family?=sama5d4
board_variant?=xplained
MACHINE?=${board_family}-${board_variant}
machine?=${board_serie}-${board_variant}
package=meta-${machine}
target_host?=${machine}
board_alias?=${board_family}x-ek
board_serie?=${board_family}
image_dir?=${TOPDIR}/sources/poky/build-${bsp}/tmp/deploy/images/${machine}
dtFile?=zImage-${boardFamily}${board_suffix}.dtb

machine_name?=${board_serie}_${board_variant}
machine_alias?=${board_vendor}${board_alias}
boardFamily?=${board_vendor}-${board_family}
board_suffix?=_${board_variant}_pda4

bootstrapFile?=${board_vendor}bootstrap-${machine_name}.bin
ubootFile?=u-boot.bin
kernelFile?=zImage-${machine}.bin
rootfsFile?=${image}-${machine}.ubi
dtFile?=zImage-${board_vendor}-${machine_name}.dtb
dtFile?=zImage-${boardFamily}${board_suffix}.dtb

layers?=${TOPDIR}/sources/poky/build-${bsp}/conf/bblayers.conf
conf?=${TOPDIR}/sources/poky/build-${bsp}/conf/local.conf
dtb_file?=${image_dir}/${boardFamily}${board_suffix}.dtb
tcl_file?=${image_dir}/${image}-${machine_name}.tcl

demo?=linux4sam-poky-sama5d4_xplained-4.6
demo_url?=ftp://www.at91.com/pub/demo/linux4sam_4.6/${demo}.zip
demo_url_dir?=$(shell echo "${demo_url}" | sed -e 's|:||g')
nandflashtcl_file?=${image_dir}/demo_script_linux_nandflash.tcl
init_build_env?=${TOPDIR}/sources/poky/oe-init-build-env
image_bb?=recipes-core/images/${image}.bb

user?=$(shell echo ${USER})
version?=0.0.$(shell date -u +%Y%m%d)${user}

dist_files?=\
 COPYING.MIT \
 README.md \
 Makefile default.xml \
 conf \
 recipes-core \
 recipes-graphics \
 recipes-qt \
 sources/poky/build-atmel/tmp/deploy/images/${MACHINE}


define BBLAYERS
BBLAYERS += " \"\
  ${TOPDIR}/sources/meta-atmel \
  ${TOPDIR}/sources/meta-openembedded/meta-oe \
  ${TOPDIR}/sources/meta-openembedded/meta-networking \
  ${TOPDIR}/sources/meta-openembedded/meta-ruby \
  ${TOPDIR}/sources/meta-qt5 \
  ${TOPDIR}/sources/meta-sama5d4-xplained \"\
"
endef
export BBLAYERS


define tcl
set bootstrapFile "${bootstrapFile}" \n\
set ubootFile "${ubootFile}" \n\
set kernelFile "${kernelFile}" \n\
set rootfsFile "${rootfsFile}" \n\
set boardFamily "${boardFamily}" \n\
set board_suffix "${board_suffix}" \n\
set use_dtb "yes" \n\
set build_uboot_env "yes" \n\
source demo_script_linux_nandflash.tcl \n\
 #eol
endef
export tcl


help: Makefile
	@echo "Usage: "
	@echo "# make all"
	@echo "USER=${USER}"
	@echo "BBLAYERS=${BBLAYERS}"
	@echo "image_dir=${image_dir}"
	@echo "sam_ba=${sam_ba}"
	@echo "nandflashtcl_file=${nandflashtcl_file}"
	@echo "# existing rules"
	@grep -o -e '^.*:' $<

all: rule/configure rule/env/build

src: .repo sync checkout


.repo: default.xml
	repo init -u . -b ${repo_branch}

sync: .repo
	time repo sync
	repo list

checkout:
	cd "${TOPDIR}/sources/poky" \
	&& git checkout -b "${USER}/${branch}"  "yocto/${branch}"

	cd "${TOPDIR}/sources/meta-openembedded" \
	&& git checkout -b "${USER}/${branch}" "oe/${branch}"

	cd "${TOPDIR}/sources/meta-atmel" \
	&& git checkout -b "${USER}/${branch}" "atmel/${branch}"

	cd "${TOPDIR}/sources/meta-qt5" \
	&& git checkout -b "${USER}/${branch}" "qt/${branch}"

	cd "${TOPDIR}/sources/meta-${MACHINE}" \
	&& git checkout -b "${USER}/${branch}" "${MACHINE}/${branch}"

	touch $@

image_bb: ${image_bb}

${image}.bb: Makefile
	touch $@

${init_build_env}: sources

init_build_env: ${init_build_env}

rule/help: rule/env/help

rule/env/%:${init_build_env}
	cd ${<D} && source ${<} build-${bsp} \
	&& make -C ${TOPDIR} ${@F} ARGS="${ARGS}"

bitbake: ${TOPDIR}/sources/poky/build-${bsp}
	cd $< && time ${@F} ${ARGS}

rule/configure: ${layers}.mine ${conf}.mine

${layers} ${conf}: sources ${init_build_env}
	@make rule/env/help

sources: .repo
	repo sync

rule/conf: ${conf}.mine

rule/layers: ${layers}.mine

${layers}.mine: ${layers} Makefile
	[ -r "${layers}.orig" ] || cp -av "${layers}" "${layers}.orig"
	echo "${BBLAYERS}" > $@
	-ls "${TOPDIR}/sources/meta-openembedded/meta-python/conf/layer.conf" \
	&&  echo 'BBLAYERS += "${TOPDIR}/sources/meta-openembedded/meta-python"' >> $@
	cat "${layers}.orig" "${layers}.mine" > "${layers}"

${conf}.mine: ${conf}
	[ -r "${conf}.orig" ] || cp -av "${conf}" "${conf}.orig"

	cp ${conf} $@
	echo 'LICENSE_FLAGS_WHITELIST += "commercial" ' >> $@
	echo 'SYSVINIT_ENABLED_GETTYS = ""' >> $@
	sed -e "s|^MACHINE ??=.*|MACHINE ?= \"${MACHINE}\"|g" -i "$@"
	sed -e 's|^PACKAGE_CLASSES ?=.*|PACKAGE_CLASSES ?= "package_ipk"|g' -i "$@"
	cp ${conf}.mine ${conf}


rule/build: ${TOPDIR}/sources/poky/build-${bsp}
	cd $< && time bitbake "${image}"


build: rule/build

tcl_file:${tcl_file}

#${nandflashtcl_file}:  ${HOME}/var/lib/arc.sh.dir/path/${HOME}/var/lib/download.sh.dir/tmp/uri/${demo_url_dir}/linux4sam-poky-sama5d4_xplained-4.6/demo_script_linux_nandflash.tcl
#	@mkdir -p ${@D}
#	cp -av "${<}" "$@"
#	@echo "TODO:"

${nandflashtcl_file}: ${demo}.zip
	unzip "$<"
	ln -fs "${TOPDIR}/${demo}/${@F}" "$@"
	touch "$@"

${demo}.zip:
	wget "${demo_url}"

${tcl_file}:${image_dir} ${nandflashtcl_file}
	echo -e "${tcl}" > "$@"

dtb: ${dtb_file}

${dtb_file}: ${image_dir}/${dtFile}
	ln -fs $< $@

${console_dev} ${flash_dev}:
	@echo "# plug EDBG-USB 1st and then A5-USB-A"
	@echo "# echo console_dev=${console_dev}"
	@echo "# echo flash_dev=${flash_dev}"

install: ${tcl_file} dtb ${flash_dev}
	ls -l ${<D}/${bootstrapFile}
	ls -l ${<D}/${rootfsFile}
	ls -l ${<D}/${ubootFile}
	ls -l ${<D}/${kernelFile}
	ls -l ${<D}/${dtFile}
	cd ${<D} && time sudo "${sam_ba}" "${flash_dev}"  "${machine_alias}" "${<F}"

console: ${console_dev}
	ls -l ${console_dev} /dev/ttyA*
	xterm -e "screen $< 115200"


clean:
	rm -rfv source/poky/build-${bsp}/tmp

distclean: clean
	rm -rfv .#*
	@echo "# make rule/purge to clean more"

rule/purge: distclean
	rm -rf .repo sources


deploy:rootfs
	ping -c 1 "${target_host}"
	ssh root@${target_host} "cat /proc/version" || \
	ssh-keygen -f "${HOME}/.ssh/known_hosts" -R ${target_host}
	rsync -avx "$</" root@${target_host}:/

rule/dizzy:
	make src sync demo repo_branch=master branch=dizzy

demo: help all install

dist: ${package}-${version}.tar.xz

${package}-${version}.tar.xz: ${dist_files}
	tar cfJv "$@" --transform "s|^|${package}-${version}/|" $^
	tar tfv "$@"


setup: /usr/local/opt/sam-ba_cdc_linux

/usr/local/opt/sam-ba_cdc_linux: sam-ba_cdc_linux
	ls "$@" && exit 1 || echo "installing"
	sudo mkdir -p ${@D}
	sudo mv "$<" "$@"

sam-ba_cdc_linux: Makefile
	wget -c "${sam_ba_url}"
	@echo "Please compare to ${sam_ba_sum}"
	sha1sum "${sam_ba_file}" | grep "${sam_ba_sum}"
	unzip "${sam_ba_file}"
