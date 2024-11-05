#!/usr/bin/env sh

OUT_IMAGE=$1
ORIG_IMAGE=$2

get_args() {
    python3 avbtool.py info_image --image $1>image_info

    args=''

    algorithm=`cat image_info|grep ^Algorithm:`
    algorithm=${algorithm##* }
    args=$args' --algorithm '${algorithm}
    if [[ $algorithm =~ .*_RSA4096 ]]; then
        args=$args' --key testkey_rsa4096.pem'
    elif [[ $algorithm =~ .*_RSA2048 ]]; then
        args=$args' --key testkey_rsa2048.pem'
    elif [[ $algorithm =~ .*_RSA8192 ]]; then
        args=$args' --key testkey_rsa8192.pem'
    fi
    #hash_algorithm=`cat image_info|grep 'Hash Algorithm:'`
    #args=$args' --hash_algorithm '${hash_algorithm##* }
    rollback_index=`cat image_info|grep '^Rollback Index:'`
    args=$args' --rollback_index '${rollback_index##* }
    rollback_index_location=`cat image_info|grep '^Rollback Index Location:'`
    args=$args' --rollback_index_location '${rollback_index_location##* }
    cat image_info|sed 's/ -> /:/g'|grep Prop:|grep -v oplus_custom_images > props
    for prop in `cat props|sed 's/Prop://g'|sed "s/'//g"`;do
        args=$args' --prop '${prop}
    done

    rm image_info props

    echo $args
}

python3 avbtool.py make_vbmeta_image $(get_args $ORIG_IMAGE) \
    --include_descriptors_from_image op13/pvmfw.img \
    --include_descriptors_from_image op12/product.img \
    --include_descriptors_from_image op12/system.img \
    --include_descriptors_from_image op12/system_ext.img \
    --output $OUT_IMAGE

