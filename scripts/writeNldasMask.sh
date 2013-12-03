
gdalwarp -overwrite \
    -t_srs EPSG:4326 \
    -te -180 -90 180 90 \
    -tr 0.08333333 0.08333333 \
    -srcnodata 9999 \
    -dstnodata 9999 \
    data/NLDAS_FORA0125_H.002/1979/001/NLDAS_FORA0125_H.A19790101.1300.002.grb \
    data/output/nldasMask5minRaw.tif

gdal_translate -ot Byte -b 1 \
    -a_nodata 255 \
    -scale \
    data/output/nldasMask5minRaw.tif \
    data/output/nldasMask5minByte.tif
