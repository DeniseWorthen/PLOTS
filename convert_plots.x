convert hykiss_z500.png  hykiss_z500.jpg
convert cfsv2_z1000.png  cfsv2_z1000.jpg
convert phc3_z500.png  phc3_z500.jpg
convert cfsv2_xsec_195_15.png  cfsv2_xsec_195_15.jpg
convert hykiss_z50.png  hykiss_z50.jpg
convert hykiss_z1000.png  hykiss_z1000.jpg
convert hykiss_xsec_195_15.png  hykiss_xsec_195_15.jpg
convert phc3_z100.png  phc3_z100.jpg
convert phc3_xsec_195_15.png  phc3_xsec_195_15.jpg
convert hykiss_z100.png  hykiss_z100.jpg
convert phc3_z1000.png  phc3_z1000.jpg
convert cfsv2_z100.png  cfsv2_z100.jpg
convert cfsv2_z50.png  cfsv2_z50.jpg
convert cfsv2_z500.png  cfsv2_z500.jpg
convert grtofs_z50.png  grtofs_z50.jpg
convert grtofs_z500.png  grtofs_z500.jpg
convert grtofs_z100.png  grtofs_z100.jpg
convert grtofs_z1000.png  grtofs_z1000.jpg
convert phc3_z50.png  phc3_z50.jpg
convert grtofs_xsec_195_15.png  grtofs_xsec_195_15.jpg

./adjoin.x -b white -m H phc3_z50.jpg cfsv2_z50.jpg top.jpg
./adjoin.x -b white -m H grtofs_z50.jpg hykiss_z50.jpg bot.jpg
./adjoin.x -b white -m V top.jpg bot.jpg z50.jpg

./adjoin.x -b white -m H phc3_z100.jpg cfsv2_z100.jpg top.jpg
./adjoin.x -b white -m H grtofs_z100.jpg hykiss_z100.jpg bot.jpg
./adjoin.x -b white -m V top.jpg bot.jpg z100.jpg

./adjoin.x -b white -m H phc3_z500.jpg cfsv2_z500.jpg top.jpg
./adjoin.x -b white -m H grtofs_z500.jpg hykiss_z500.jpg bot.jpg
./adjoin.x -b white -m V top.jpg bot.jpg z500.jpg

./adjoin.x -b white -m H phc3_z1000.jpg cfsv2_z1000.jpg top.jpg
./adjoin.x -b white -m H grtofs_z1000.jpg hykiss_z1000.jpg bot.jpg
./adjoin.x -b white -m V top.jpg bot.jpg z1000.jpg


./adjoin.x -b white -m H phc3_xsec_195_15.jpg cfsv2_xsec_195_15.jpg top.jpg
./adjoin.x -b white -m H grtofs_xsec_195_15.jpg hykiss_xsec_195_15.jpg bot.jpg
./adjoin.x -b white -m V top.jpg bot.jpg xsec_195_15.jpg

