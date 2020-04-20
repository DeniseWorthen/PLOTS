undef("regionTS")

function regionTS(regname,zdepth,xsection)
;************************************************
; arrays for depth dependent contour levels
;************************************************
begin

 ; the levels at which the T,S are defined
 zlevs = (/0.0, 100.0, 200.0, 500.0, 1000.0/)

  klev = closest_val(zdepth,zlevs)
  ; use 1 up for xsections
  if(xsection .and. klev .ge. 1)then
     klev = klev-1
  end if
  print("found contour intervals at klev = "+klev+" for depth "+zdepth)

 if(regname .eq. "NPole")then
;************************************************
;
;************************************************

  ; alt choices
  ;tlevs_NPole(3,:) = (/ (/ 500.0,  -0.8,    1.8,  0.050/) /)
  ;slevs_NPole(3,:) = (/ (/ 500.0,  34.60,  35.02,  0.010/) /)

       tlevs_NPole = new((/5,4/),float)
       slevs_NPole = new((/5,4/),float)

  tlevs_NPole(0,:) = (/ (/   0.0,  -1.7,   -1.5,  0.005/) /)
  ;tlevs_NPole(0,:) = (/ (/   0.0,  -1.8,   -1.2,  0.010/) /)
  tlevs_NPole(1,:) = (/ (/ 100.0,  -1.4,    0.6,  0.020/) /)
  tlevs_NPole(2,:) = (/ (/ 200.0,  -0.2,    3.0,  0.050/) /)
  tlevs_NPole(3,:) = (/ (/ 500.0,   0.0,    1.2,  0.020/) /)
  tlevs_NPole(4,:) = (/ (/1000.0,  -0.7,    0.7,  0.025/) /)

  slevs_NPole(0,:) = (/ (/   0.0,  28.40,  35.20,  0.200/) /)
  slevs_NPole(1,:) = (/ (/ 100.0,  31.60,  34.80,  0.050/) /)
  slevs_NPole(2,:) = (/ (/ 200.0,  33.50,  35.10,  0.025/) /)
  slevs_NPole(3,:) = (/ (/ 500.0,  34.80,  35.00,  0.005/) /)
  slevs_NPole(4,:) = (/ (/1000.0,  34.86,  34.94,  0.002/) /)

  tlevs = tlevs_NPole(klev,1:3)
  slevs = slevs_NPole(klev,1:3)
 end if 

 if(regname .eq. "GIN")then
;************************************************
;
;************************************************

     tlevs_GIN   = new((/5,4/),float)
     slevs_GIN   = new((/5,4/),float)

  tlevs_GIN(0,:) = (/ (/   0.0,  -1.8,   6.0,   0.200/) /)
  tlevs_GIN(1,:) = (/ (/ 100.0,  -1.5,   2.0,   0.200/) /)
  tlevs_GIN(2,:) = (/ (/ 200.0,  -1.0,   6.0,   0.500/) /)
  tlevs_GIN(3,:) = (/ (/ 500.0,  -0.5,   3.5,   0.050/) /)
  tlevs_GIN(4,:) = (/ (/1000.0,  -0.4,   2.0,   0.020/) /)

  slevs_GIN(0,:) = (/ (/   0.0,  32.20,  35.35,  0.050/) /)
  slevs_GIN(1,:) = (/ (/   0.0,  32.50,  36.35,  0.050/) /)
  slevs_GIN(2,:) = (/ (/ 200.0,  34.20,  35.20,  0.050/) /)
  slevs_GIN(3,:) = (/ (/ 500.0,  34.82,  35.02,  0.010/) /)
  slevs_GIN(4,:) = (/ (/1000.0,  34.86,  34.94,  0.002/) /)

  tlevs = tlevs_GIN(klev,1:3)
  slevs = slevs_GIN(klev,1:3)
 end if

 if(regname .eq. "NAtl")then
;************************************************
;
;************************************************

     tlevs_NAtl  = new((/5,4/),float)
     slevs_NAtl  = new((/5,4/),float)

  tlevs_NAtl(0,:) = (/ (/   0.0,   0.0,   29.0,  1.000/) /)
  tlevs_NAtl(1,:) = (/ (/ 100.0,   0.0,   23.0,  0.500/) /)
  tlevs_NAtl(2,:) = (/ (/ 200.0,   0.0,   20.0,  0.500/) /)
  tlevs_NAtl(3,:) = (/ (/ 500.0,   2.0,   17.0,  0.500/) /)
  tlevs_NAtl(4,:) = (/ (/1000.0,   2.0,   10.0,  0.200/) /)

  slevs_NAtl(0,:) = (/ (/   0.0,  30.00,  38.50,  0.200/) /)
  slevs_NAtl(1,:) = (/ (/ 100.0,  33.00,  36.80,  0.100/) /)
  slevs_NAtl(2,:) = (/ (/ 200.0,  34.50,  37.00,  0.100/) /)
  slevs_NAtl(3,:) = (/ (/ 500.0,  34.80,  36.50,  0.100/) /)
  slevs_NAtl(4,:) = (/ (/1000.0,  34.80,  35.80,  0.020/) /)

  tlevs = tlevs_NAtl(klev,1:3)
  slevs = slevs_NAtl(klev,1:3)
 end if

 if(regname .eq. "SPole")then
;************************************************
;
;************************************************

       tlevs_SPole = new((/5,4/),float)
       slevs_SPole = new((/5,4/),float)

  tlevs_SPole(0,:) = (/ (/   0.0,  -1.8,   -1.2,  0.010/) /)
  tlevs_SPole(1,:) = (/ (/ 100.0,  -1.4,    0.6,  0.020/) /)
  tlevs_SPole(2,:) = (/ (/ 200.0,  -0.2,    3.0,  0.050/) /)
  tlevs_SPole(3,:) = (/ (/ 500.0,  -0.8,    1.8,  0.050/) /)
  tlevs_SPole(4,:) = (/ (/1000.0,  -0.7,    0.7,  0.025/) /)

  slevs_SPole(0,:) = (/ (/   0.0,  28.40,  35.20,  0.200/) /)
  slevs_SPole(1,:) = (/ (/ 100.0,  31.60,  34.80,  0.050/) /)
  slevs_SPole(2,:) = (/ (/ 200.0,  33.50,  35.10,  0.025/) /)
  slevs_SPole(3,:) = (/ (/ 500.0,  34.60,  35.02,  0.010/) /)
  slevs_SPole(4,:) = (/ (/1000.0,  34.86,  34.94,  0.002/) /)

  tlevs = tlevs_SPole(klev,1:3)
  slevs = slevs_SPole(klev,1:3)
 end if

;************************************************
;
;************************************************

  ; an array for depth dependent vector settings
  ; depth,vmag,vthin
  vecvals = new((/5,3/),float)
  vecvals(0,:) = (/ (/   0.0, 0.020, 0.008/) /)
  vecvals(1,:) = (/ (/ 100.0, 0.020, 0.008/) /)
  vecvals(2,:) = (/ (/ 200.0, 0.100, 0.008/) /)
  vecvals(3,:) = (/ (/ 500.0, 0.010, 0.008/) /)
  vecvals(4,:) = (/ (/1000.0, 0.010, 0.008/) /)

   ;klev = closest_val(zdepth,vecvals(:,0))
  vlevs = vecvals(klev,:)
  print(vlevs)

  return(/tlevs,slevs,vlevs/)
end
