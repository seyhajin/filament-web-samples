#!/usr/bin/env bash

# tools
matc=./tools/matc
cmgen=./tools/cmgen
filamesh=./tools/filamesh
mipgen=./tools/mipgen

# dirs
assets=./assets
environments=$assets/environments
images=$assets/images
materials=$assets/materials
models=$assets/models

#--------------------------
# make 'Red ball' assets
#--------------------------

# produces a binary material package that contains shader code ans associated metadata
$matc --a opengl --p mobile --o $materials/plastic.filamat $materials/plastic.mat

# produce two cubemap files: a mipmapped IBL and a blurry skybox
$cmgen -x $environments/pillars_2k --format=ktx --size=256 --extract-blur=0.1 $environments/pillars_2k.hdr

#--------------------------
# make 'Suzanne' assets
#--------------------------

# create a compressed filamesh file for suzanne by converting this OBJ file
$filamesh --compress $models/monkey.obj $models/monkey.filamesh

# create compressed and non-compressed variants for each texture, since not all 
# platforms support the same compression formats

# create mipmaps for base color and two compressed variants
$mipgen $models/albedo.png $models/albedo.ktx
$mipgen --compression=astc_fast_ldr_4x4 $models/albedo.png $models/albedo_astc.ktx
$mipgen --compression=s3tc_rgb_dxt1 $models/albedo.png $models/albedo_s3tc_srgb.ktx

# create mipmaps for the normal map and a compressed variant.
$mipgen --strip-alpha --kernel=NORMALS --linear $models/normal.png $models/normal.ktx
$mipgen --strip-alpha --kernel=NORMALS --linear --compression=etc_rgb8_normalxyz_40 $models/normal.png $models/normal_etc.ktx

# create mipmaps for the single-component roughness map and a compressed variant.
$mipgen --grayscale $models/roughness.png $models/roughness.ktx
$mipgen --grayscale --compression=etc_r11_numeric_40 $models/roughness.png $models/roughness_etc.ktx

# create mipmaps for the single-component metallic map and a compressed variant.
$mipgen --grayscale $models/metallic.png $models/metallic.ktx
$mipgen --grayscale --compression=etc_r11_numeric_40 $models/metallic.png $models/metallic_etc.ktx

# create mipmaps for the single-component occlusion map and a compressed variant.
$mipgen --grayscale $models/ao.png $models/ao.ktx
$mipgen --grayscale --compression=etc_r11_numeric_40 $models/ao.png $models/ao_etc.ktx

# produce two cubemap files (64x64)
$cmgen -x $environments/venetian_crossroads_2k --format=ktx --size=64 --extract-blur=0.1 $environments/venetian_crossroads_2k.hdr

#rename to *_tiny.ktx
mv $environments/venetian_crossroads_2k/venetian*_ibl.ktx $environments/venetian_crossroads_2k/venetian_crossroads_2k_skybox_tiny.ktx

# produce two cubemap files (256x256)
$cmgen -x $environments/venetian_crossroads_2k --format=ktx --size=256 --extract-blur=0.1 $environments/venetian_crossroads_2k.hdr

# produces a binary material package
$matc --a opengl --p mobile --o $materials/textured.filamat $materials/textured.mat