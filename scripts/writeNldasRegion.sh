
gdalwarp -overwrite \
    -t_srs EPSG:4326 \
    -tr 0.08333333 0.08333333 \
    -srcnodata 9999 \
    -dstnodata 9999 \
    # data/NLDAS_FORA0125_H.002/1979/001/NLDAS_FORA0125_H.A19790101.1300.002.grb \
    $( find data/NLDAS_FORA0125_H.002 -type f -name "*.grb" | head -n 1) \
    data/output/nldasRegionRaw.tif

gdal_translate -ot Byte -b 1 \
    -a_nodata 255 \
    -scale \
    data/output/nldasRegionRaw.tif \
    data/output/nldasRegionByte.tif
