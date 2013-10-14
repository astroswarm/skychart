unit cu_plansat;
{
Copyright Xplanet project & Patrick Chevalley

http://xplanet.sourceforge.net
http://www.ap-i.net
pch@ap-i.net

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}
{
Rewrite for Pascal language of libmoons from the Xplanet project.
As Xplanet itself is used for the planet disk rendering this
ensure the satellites positions computed in Skychart and Xplanet
are the same.
}

interface

uses u_util;

type
double8 = array[1..8] of double;

function MarSatAll(jde: double; var xsat,ysat,zsat : double8):integer;
function JupSatAll(jde: double; var xsat,ysat,zsat : double8):integer;

implementation

type
Tbody =(
    SUN,
    MERCURY,
    VENUS,
    EARTH, MOON,
    MARS, PHOBOS, DEIMOS,
    JUPITER, IO, EUROPA, GANYMEDE, CALLISTO,
    SATURN, MIMAS, ENCELADUS, TETHYS, DIONE, RHEA, TITAN, HYPERION, IAPETUS, PHOEBE,
    URANUS, MIRANDA, ARIEL, UMBRIEL, TITANIA, OBERON,
    NEPTUNE, TRITON, NEREID,
    PLUTO, CHARON,
    RANDOM_BODY,    // RANDOM_BODY needs to be after the last "real" body
    ABOVE_ORBIT, ALONG_PATH, BELOW_ORBIT, DEFAULT, MAJOR_PLANET, NAIF, NORAD, SAME_SYSTEM, UNKNOWN_BODY
    );

const deg_to_rad = pi/180.0;
      AU_to_km = 149597870.66;

procedure rotateX(var X, Y, Z: double; theta:double);
var st,ct,X0,Y0,Z0: double;
begin
    st := sin(theta);
    ct := cos(theta);
    X0 := X;
    Y0 := Y;
    Z0 := Z;

    X := X0;
    Y := Y0 * ct + Z0 * st;
    Z := Z0 * ct - Y0 * st;
end;

procedure rotateZ(var X, Y, Z: double; theta:double);
var st,ct,X0,Y0,Z0: double;
begin
    st := sin(theta);
    ct := cos(theta);
    X0 := X;
    Y0 := Y;
    Z0 := Z;

    X := X0 * ct + Y0 * st;
    Y := Y0 * ct - X0 * st;
    Z := Z0;
end;

//  Precess rectangular coordinates in B1950 frame to J2000 using
//  Standish precession matrix from Lieske (1998)
procedure precessB1950J2000(var X, Y, Z:double);
const p: array[0..2,0..2] of double =
        ( ( 0.9999256791774783, -0.0111815116768724, -0.0048590038154553 ),
          ( 0.0111815116959975,  0.9999374845751042, -0.0000271625775175 ),
          ( 0.0048590037714450, -0.0000271704492210,  0.9999881946023742 ) );
var newX,newY,newZ: double;
begin
    newX := p[0][0] * X + p[0][1] * Y + p[0][2] * Z;
    newY := p[1][0] * X + p[1][1] * Y + p[1][2] * Z;
    newZ := p[2][0] * X + p[2][1] * Y + p[2][2] * Z;

    X := newX;
    Y := newY;
    Z := newZ;
end;

function kepler(e,M: double):double;
var delta: double;
begin
    M:=rmod(M,2*pi);
    result:=M;
    delta := 1;
    while (abs(delta) > 1E-10) do begin
        delta := (M + e * sin(result) - result)/(1 - e * cos(result));
        result += delta;
    end;
end;

function marsat(jd:double; b:Tbody; var X,Y,Z: double):boolean;
{
  Ephemerides for Phobos and Deimos are described in Sinclair,
  Astron. Astrophys. 220, 321-328 (1989)
}
var td,ty,dL,ma,EE,omega: double;
    a: double;        // semimajor axis
    e: double;        // eccentricity
    I: double;        // inclination of orbit to Laplacian plane

    L: double;        // mean longitude
    P: double;        // longitude of pericenter
    K: double;        // longitude of node of orbit on Laplacian plane

    N: double;        // node of the Laplacian plane on the Earth
                      // equator B1950
    J: double;        // inclination of Laplacian plane with respect to
                      // the Earth equator B1950
begin
    td := jd - 2441266.5;
    ty := td/365.25;


    case b of
    PHOBOS: begin
        a := 9379.40;
        e := 0.014979;
        I := 1.1029 * deg_to_rad;
        L := (232.412 + 1128.8445566 * td + 0.001237 * ty * ty) * deg_to_rad;
        P := (278.96 + 0.435258 * td) * deg_to_rad;
        K := (327.90 - 0.435330 * td) * deg_to_rad;
        N := (47.386 - 0.00140 * ty) * deg_to_rad;
        J := (37.271 + 0.00080 * ty) * deg_to_rad;
       end;
    DEIMOS: begin
        a := 23461.13;
        e := 0.000391;
        I := 1.7901 * deg_to_rad;
        P := (111.7 + 0.017985 * td) * deg_to_rad;
        L := (28.963 + 285.1618875 * td) * deg_to_rad;
        K := (240.38 - 0.018008 * td) * deg_to_rad;
        N := (46.367 - 0.00138 * ty) * deg_to_rad;
        J := (36.623 + 0.00079 * ty) * deg_to_rad;

        dL := -0.274 * sin(K - 43.83 * deg_to_rad) * deg_to_rad;
        L += dL;
        end;
    else
        result:=false;
    end;
    ma := L - P;
    EE := kepler(e, ma);

    // convert semi major axis from km to AU
    a /= AU_to_km;

    // rectangular coordinates on the orbit plane, x-axis is toward
    // pericenter
    X := a * (cos(EE) - e);
    Y := a * sqrt(1 - e*e) * sin(EE);
    Z := 0;

    // longitude of pericenter measured from ascending node of the
    // orbit on the Laplacian plane
    omega := P - (K + N);

    // rotate towards ascending node of the orbit on the Laplacian
    // plane
    rotateZ(X, Y, Z, -omega);

    // rotate towards Laplacian plane
    rotateX(X, Y, Z, -I);

    // rotate towards ascending node of the Laplacian plane on the
    // Earth equator B1950
    rotateZ(X, Y, Z, -K);

    // rotate towards Earth equator B1950
    rotateX(X, Y, Z, -J);

    // rotate to vernal equinox
    rotateZ(X, Y, Z, -N);

    // precess to J2000
    precessB1950J2000(X, Y, Z);
end;


function jupsat(jd:double; b:Tbody; var X,Y,Z: double):boolean;
{
  The Galilean satellite ephemerides E5 are described in Lieske,
  Astron. Astrophys. Suppl. Ser., 129, 205-217 (1998)
}
  procedure computeArguments(t:double; var l1,l2,l3,l4,om1,om2,om3,om4,psi,Gp,G : double);
  begin
      // mean longitudes
      l1 := (106.077187 + 203.48895579033 * t) * deg_to_rad;
      l2 := (175.731615 + 101.37472473479 * t) * deg_to_rad;
      l3 := (120.558829 +  50.31760920702 * t) * deg_to_rad;
      l4 := ( 84.444587 +  21.57107117668 * t) * deg_to_rad;

      // proper nodes
      om1 := (312.334566 - 0.13279385940 * t) * deg_to_rad;
      om2 := (100.441116 - 0.03263063731 * t) * deg_to_rad;
      om3 := (119.194241 - 0.00717703155 * t) * deg_to_rad;
      om4 := (322.618633 - 0.00175933880 * t) * deg_to_rad;

      // longitude of origin of coordingate (Jupiter's pole)
      psi := (316.518203 - 2.08362E-06 * t) * deg_to_rad;

      // mean anomaly of Saturn
      Gp := (31.978528 + 0.03345973390 * t) * deg_to_rad;

      // mean anomaly of Jupiter
      G := (30.237557 + 0.08309257010 * t) * deg_to_rad;
  end;

var t: double;
    phi,pi1,pi2,pi3,pi4,PIj,phi1,phi2,phi3,phi4: double;
    axis1,axis2,axis3,axis4,PIG2: double;
    xi,upsilon,zeta,radius,lon,n,I,OM,J,eps : double;
    // mean longitudes
    l1, l2, l3, l4: double;
    // proper nodes
    om1, om2, om3, om4: double;
    // longitude of origin of coordinates (Jupiter's pole)
    psi: double;
    // mean anomaly of Saturn
    Gp: double;
    // mean anomaly of Jupiter
    G: double;

begin
    t := jd - 2443000.5;

    computeArguments(t, l1, l2, l3, l4, om1, om2, om3, om4, psi, Gp, G);
    
    // free libration
    phi := (199.676608 + 0.17379190461 * t) * deg_to_rad;

    // periapse longitudes
    pi1 := ( 97.088086 + 0.16138586144 * t) * deg_to_rad;
    pi2 := (154.866335 + 0.04726306609 * t) * deg_to_rad;
    pi3 := (188.184037 + 0.00712733949 * t) * deg_to_rad;
    pi4 := (335.286807 + 0.00183999637 * t) * deg_to_rad;

    // longitude of perihelion of jupiter
    PIj := 13.469942 * deg_to_rad;
    
    // phase angles
    phi1 := 188.374346 * deg_to_rad;
    phi2 :=  52.224824 * deg_to_rad;
    phi3 := 257.184000 * deg_to_rad;
    phi4 := 149.152605 * deg_to_rad;

    // semimajor axes, in AU
    axis1 :=  2.819353E-3;
    axis2 :=  4.485883E-3;
    axis3 :=  7.155366E-3;
    axis4 := 12.585464E-3;

    // common factors
    PIG2 := (PIj + G) * 2;

    xi := 0;
    upsilon := 0;
    zeta := 0;

    case b of
    IO: begin
        lon := l1;

        xi += 170 * cos(l1 - l2);
        xi += 106 * cos(l1 - l3);
        xi += -2 * cos(l1 - pi1);
        xi += -2 * cos(l1 - pi2);
        xi += -387 * cos(l1 - pi3);
        xi += -214 * cos(l1 - pi4);
        xi += -66 * cos(l1 + pi3 - PIG2);
        xi += -41339 * cos(2*(l1 - l2));
        xi += 3 * cos(2*(l1 - l3));
        xi += -131 * cos(4*(l1-l2));
        xi *= 1e-7;

        radius := axis1 * (1 + xi);

        upsilon +=    -26 * sin( 2 * psi - PIG2 );
        upsilon +=   -553 * sin( 2*(psi - PIj) );
        upsilon +=   -240 * sin( om3 + psi - PIG2 );
        upsilon +=     92 * sin( psi - om2 );
        upsilon +=    -72 * sin( psi - om3 );
        upsilon +=    -49 * sin( psi - om4 );
        upsilon +=   -325 * sin( G );
        upsilon +=     65 * sin( 2*G );
        upsilon +=    -33 * sin( 5*Gp - 2*G + phi2 );
        upsilon +=    -27 * sin( om3 - om4 );
        upsilon +=    145 * sin( om2 - om3 );
        upsilon +=     30 * sin( om2 - om4 );
        upsilon +=    -38 * sin( pi4 - PIj );
        upsilon +=  -6071 * sin( pi3 - pi4 );
        upsilon +=    282 * sin( pi2 - pi3 );
        upsilon +=    156 * sin( pi2 - pi4 );
        upsilon +=    -38 * sin( pi1 - pi3 );
        upsilon +=    -25 * sin( pi1 - pi4 );
        upsilon +=    -27 * sin( pi1 + pi4 - PIG2 );
        upsilon +=  -1176 * sin( pi1 + pi3 - PIG2 );
        upsilon +=   1288 * sin( phi );
        upsilon +=     39 * sin( 3*l3 - 7*l4 + 4*pi4 );
        upsilon +=    -32 * sin( 3*l3 - 7*l4 + pi3 + 3*pi4 );
        upsilon +=  -1162 * sin( l1 - 2*l2 + pi4 );
        upsilon +=  -1887 * sin( l1 - 2*l2 + pi3 );
        upsilon +=  -1244 * sin( l1 - 2*l2 + pi2 );
        upsilon +=     38 * sin( l1 - 2*l2 + pi1 );
        upsilon +=   -617 * sin( l1 - l2 );
        upsilon +=   -270 * sin( l1 - l3 );
        upsilon +=    -26 * sin( l1 - l4 );
        upsilon +=      4 * sin( l1 - pi1 );
        upsilon +=      5 * sin( l1 - pi2 );
        upsilon +=    776 * sin( l1 - pi3 );
        upsilon +=    462 * sin( l1 - pi4 );
        upsilon +=    149 * sin( l1 + pi3 - PIG2 );
        upsilon +=     21 * sin( 2*l1 - 4*l2 + om2 + om3 );
        upsilon +=   -200 * sin( 2*l1 - 4*l2 + 2*om2 );
        upsilon +=  82483 * sin( 2*(l1 - l2) );
        upsilon +=    -35 * sin( 2*(l1 - l3) );
        upsilon +=     -3 * sin( 3*l1 - 4*l2 + pi3 );
        upsilon +=    276 * sin( 4*(l1 - l2) );
        upsilon *= 1e-7;

        // now use the "time completed" series
        n := 203.48895579033 * deg_to_rad;
        computeArguments(t + upsilon/n, l1, l2, l3, l4,
                         om1, om2, om3, om4, psi, Gp, G);

        zeta +=    46 * sin( l1 + psi - 2*PIj - 2*G);
        zeta +=  6393 * sin( l1 - om1 );
        zeta +=  1825 * sin( l1 - om2 );
        zeta +=   329 * sin( l1 - om3 );
        zeta +=    93 * sin( l1 - om4 );
        zeta +=  -311 * sin( l1 - psi );
        zeta +=    75 * sin( 3*l1 - 4*l2 + om2 );
        zeta *= 1e-7;
        result:=true;
    end;

    EUROPA: begin
        lon := l2;

        xi +=    -18 * cos( om2 - om3 );
        xi +=    -27 * cos( 2*l3 - PIG2 );
        xi +=    553 * cos( l2 - l3 );
        xi +=     45 * cos( l2 - l4 );
        xi +=   -102 * cos( l2 - pi1 );
        xi +=  -1442 * cos( l2 - pi2 );
        xi +=  -3116 * cos( l2 - pi3 );
        xi +=  -1744 * cos( l2 - pi4 );
        xi +=    -15 * cos( l2 - PIj - G );
        xi +=    -64 * cos( 2*(l2 - l4) );
        xi +=    164 * cos( 2*(l2 - om2) );
        xi +=     18 * cos( 2*l2 - om2 - om3 );
        xi +=    -54 * cos( 5*(l2 - l3) );
        xi +=    -30 * cos( l1 - 2*l2 + pi4 );
        xi +=    -67 * cos( l1 - 2*l2 + pi3 );
        xi +=  93848 * cos( l1 - l2 );
        xi +=     48 * cos( l1 - 2*l3 + pi4 );
        xi +=    107 * cos( l1 - 2*l3 + pi3 );
        xi +=    -19 * cos( l1 - 2*l3 + pi2 );
        xi +=    523 * cos( l1 - l3 );
        xi +=     30 * cos( l1 - pi3 );
        xi +=   -290 * cos( 2*(l1 - l2) );
        xi +=    -91 * cos( 2*(l1 - l3) );
        xi +=     22 * cos( 4*(l1 - l2) );
        xi *= 1e-7;

        radius := axis2 * (1 + xi);

        upsilon +=       98 * sin( 2*psi - PIG2 );
        upsilon +=    -1353 * sin( 2*(psi - PIj) );
        upsilon +=      551 * sin( psi + om3 - PIG2 );
        upsilon +=       26 * sin( psi + om2 - PIG2 );
        upsilon +=       31 * sin( psi - om2 );
        upsilon +=      255 * sin( psi - om3 );
        upsilon +=      218 * sin( psi - om4 );
        upsilon +=    -1845 * sin( G);
        upsilon +=     -253 * sin( 2*G );
        upsilon +=       18 * sin( 2*(Gp - G) + phi4 );
        upsilon +=       19 * sin( 2*Gp - G + phi1 );
        upsilon +=      -15 * sin( 5*Gp - 3*G + phi1 );
        upsilon +=     -150 * sin( 5*G - 2*G + phi2 );
        upsilon +=      102 * sin( om3 - om4 );
        upsilon +=       56 * sin( om2 - om3 );
        upsilon +=       72 * sin( pi4 - PIj );
        upsilon +=     2259 * sin( pi3 - pi4 );
        upsilon +=      -24 * sin( pi3 - pi4 + om3 - om4 );
        upsilon +=      -23 * sin( pi2 - pi3 );
        upsilon +=      -36 * sin( pi2 - pi4 );
        upsilon +=      -31 * sin( pi1 - pi2 );
        upsilon +=        4 * sin( pi1 - pi3 );
        upsilon +=      111 * sin( pi1 - pi4 );
        upsilon +=     -354 * sin( pi1 + pi3 - PIG2 );
        upsilon +=    -3103 * sin( phi );
        upsilon +=       55 * sin( 2*l3 - PIG2 );
        upsilon +=     -111 * sin( 3*l3 - 7*l4 + 4*pi4 );
        upsilon +=       91 * sin( 3*l3 - 7*l4 + pi3 + 3*pi4 );
        upsilon +=      -25 * sin( 3*l3 - 7*l4 + 2*pi3 + 2*pi4 );
        upsilon +=    -1994 * sin( l2 - l3 );
        upsilon +=     -137 * sin( l2 - l4 );
        upsilon +=        1 * sin( l2 - pi1 );
        upsilon +=     2886 * sin( l2 - pi2 );
        upsilon +=     6250 * sin( l2 - pi3 );
        upsilon +=     3463 * sin( l2 - pi4 );
        upsilon +=       30 * sin( l2 - PIj - G );
        upsilon +=      -18 * sin( 2*l2 - 3*l3 + pi4 );
        upsilon +=      -39 * sin( 2*l2 - 3*l3 + pi3 );
        upsilon +=       98 * sin( 2*(l2 - l4) );
        upsilon +=     -164 * sin( 2*(l2 - om2) );
        upsilon +=      -18 * sin( 2*l2 - om2 - om3 );
        upsilon +=       72 * sin( 5*(l2 - l3) );
        upsilon +=       30 * sin( l1 - 2*l2 - pi3 + PIG2 );
        upsilon +=     4180 * sin( l1 - 2*l2 + pi4 );
        upsilon +=     7428 * sin( l1 - 2*l2 + pi3 );
        upsilon +=    -2329 * sin( l1 - 2*l2 + pi2 );
        upsilon +=      -19 * sin( l1 - 2*l2 + pi1 );
        upsilon +=  -185835 * sin( l1 - l2 );
        upsilon +=     -110 * sin( l1 - 2*l3 + pi4 );
        upsilon +=     -200 * sin( l1 - 2*l3 + pi3 );
        upsilon +=       39 * sin( l1 - 2*l3 + pi2 );
        upsilon +=      -16 * sin( l1 - 2*l3 + pi1 );
        upsilon +=     -803 * sin( l1 - l3 );
        upsilon +=      -19 * sin( l1 - pi2 );
        upsilon +=      -75 * sin( l1 - pi3 );
        upsilon +=      -31 * sin( l1 - pi4 );
        upsilon +=       -9 * sin( 2*l1 - 4*l2 + om3 + psi );
        upsilon +=        4 * sin( 2*l1 - 4*l2 + 2*om3 );
        upsilon +=      -14 * sin( 2*l1 - 4*l2 + om2 + om3 );
        upsilon +=      150 * sin( 2*l1 - 4*l2 + 2*om2 );
        upsilon +=      -11 * sin( 2*l1 - 4*l2 + PIG2 );
        upsilon +=       -9 * sin( 2*l1 - 4*l2 + pi3 + pi4 );
        upsilon +=       -8 * sin( 2*l1 - 4*l2 + 2*pi3 );
        upsilon +=      915 * sin( 2*(l1 - l2) );
        upsilon +=       96 * sin( 2*(l1 - l3) );
        upsilon +=      -18 * sin( 4*(l1 - l2) );
        upsilon *= 1e-7;

        // now use the "time completed" series
        n := 101.37472473479 * deg_to_rad;
        computeArguments(t + upsilon/n, l1, l2, l3, l4,
                         om1, om2, om3, om4, psi, Gp, G);

        zeta +=     17 * sin( l2 + psi - 2*(PIj - G) - G );
        zeta +=    143 * sin( l2 + psi - 2*(PIj - G) );
        zeta +=   -144 * sin( l2 - om1 );
        zeta +=  81004 * sin( l2 - om2 );
        zeta +=   4512 * sin( l2 - om3 );
        zeta +=   1160 * sin( l2 - om4 );
        zeta +=    -19 * sin( l2 - psi - G );
        zeta +=  -3284 * sin( l2 - psi );
        zeta +=     35 * sin( l2 - psi + G );
        zeta +=    -28 * sin( l1 - 2*l3 + om3 );
        zeta +=    272 * sin( l1 - 2*l3 + om2 );
        zeta *= 1e-7;
        result:=true;
      end;
    GANYMEDE: begin
        lon := l3;

        xi +=      24 * cos( psi - om3 );
        xi +=      -9 * cos( om3 - om4 );
        xi +=      10 * cos( pi3 - pi4 );
        xi +=     294 * cos( l3 - l4 );
        xi +=      18 * cos( l3 - pi2 );
        xi +=  -14388 * cos( l3 - pi3 );
        xi +=   -7919 * cos( l3 - pi4 );
        xi +=     -23 * cos( l3 - PIj - G );
        xi +=     -20 * cos( l3 + pi4 - PIG2 );
        xi +=     -51 * cos( l3 + pi3 - PIG2 );
        xi +=      39 * cos( 2*l3 - 3*l4 + pi4 );
        xi +=   -1761 * cos( 2*(l3 - l4) );
        xi +=     -11 * cos( 2*(l3 - pi3) );
        xi +=     -10 * cos( 2*(l3 - pi3 - pi4) );
        xi +=     -27 * cos( 2*l3 - PIG2 );
        xi +=      24 * cos( 2*(l3 - om3) );
        xi +=       9 * cos( 2 * l3 - om3 - om4 );
        xi +=     -24 * cos( 2 * l3 - om3 - psi );
        xi +=     -16 * cos( 3*l3 - 4*l4 + pi4 );
        xi +=    -156 * cos( 3*(l3 - l4) );
        xi +=     -42 * cos( 4*(l3 - l4) );
        xi +=     -11 * cos( 5*(l3 - l4) );
        xi +=    6342 * cos( l2 - l3 );
        xi +=       9 * cos( l2 - pi3 );
        xi +=      39 * cos( 2*l2 - 3*l3 + pi4 );
        xi +=      70 * cos( 2*l2 - 3*l3 + pi3 );
        xi +=      10 * cos( l1 - 2*l2 + pi4 );
        xi +=      20 * cos( l1 - 2*l2 + pi3 );
        xi +=    -153 * cos( l1 - l2 );
        xi +=     156 * cos( l1 - l3 );
        xi +=      11 * cos( 2*(l1 - l2) );
        xi *= 1e-7;

        radius := axis3 * (1 + xi);

        upsilon +=     10 * sin( psi - pi3 + pi4 - om3 );
        upsilon +=     28 * sin( 2*psi - PIG2 );
        upsilon +=  -1770 * sin( 2*(psi - PIj) );
        upsilon +=    -48 * sin( psi + om3 - PIG2 );
        upsilon +=     14 * sin( psi - om2 );
        upsilon +=    411 * sin( psi - om3 );
        upsilon +=    345 * sin( psi - om4 );
        upsilon +=  -2338 * sin( G );
        upsilon +=    -66 * sin( 2*G );
        upsilon +=     10 * sin( Gp - G + phi3 );
        upsilon +=     22 * sin( 2*(Gp - G) + phi4 );
        upsilon +=     26 * sin( 2*Gp - G + phi1 );
        upsilon +=     11 * sin( 3*Gp - 2*G + phi2 + phi3 );
        upsilon +=      9 * sin(  3*Gp - G + phi1 - phi2 );
        upsilon +=    -19 * sin( 5*Gp - 3*G + phi1 );
        upsilon +=   -208 * sin( 5*Gp - 2*G + phi2 );
        upsilon +=    159 * sin( om3 - om4 );
        upsilon +=     21 * sin( om2 - om3 );
        upsilon +=    121 * sin( pi4 - PIj );
        upsilon +=   6604 * sin( pi3 - pi4 );
        upsilon +=    -65 * sin( pi3 - pi4 + om3 - om4 );
        upsilon +=    -88 * sin( pi2 - pi3 );
        upsilon +=    -72 * sin( pi2 - pi4 );
        upsilon +=    -26 * sin( pi1 - pi3 );
        upsilon +=     -9 * sin( pi1 - pi4 );
        upsilon +=     16 * sin( pi1 + pi4 - PIG2 );
        upsilon +=    125 * sin( pi1 + pi3 - PIG2 );
        upsilon +=    307 * sin( phi );
        upsilon +=    -10 * sin( l4 - pi4 );
        upsilon +=   -100 * sin( l3 - 2*l4 + pi4 );
        upsilon +=     83 * sin( l3 - 2*l4 + pi3 );
        upsilon +=   -944 * sin( l3 - l4 );
        upsilon +=    -37 * sin( l3 - pi2 );
        upsilon +=  28780 * sin( l3 - pi3 );
        upsilon +=  15849 * sin( l3 - pi4 );
        upsilon +=      7 * sin( l3 - pi4 + om3 - om4 );
        upsilon +=     46 * sin( l3 - PIj - G );
        upsilon +=     51 * sin( l3 + pi4 - PIG2 );
        upsilon +=     11 * sin( l3 + pi3 - PIG2 - G );
        upsilon +=     97 * sin( l3 + pi3 - PIG2 );
        upsilon +=      1 * sin( l3 + pi1 - PIG2 );
        upsilon +=   -101 * sin( 2*l3 - 3*l4 + pi4 );
        upsilon +=     13 * sin( 2*l3 - 3*l4 + pi3 );
        upsilon +=   3222 * sin( 2*(l3 - l4) );
        upsilon +=     29 * sin( 2*(l3 - pi3) );
        upsilon +=     25 * sin( 2*l3 - pi3 - pi4 );
        upsilon +=     37 * sin( 2*l3 - PIG2 );
        upsilon +=    -24 * sin( 2*(l3 - om3) );
        upsilon +=     -9 * sin( 2*l3 - om3 - om4 );
        upsilon +=     24 * sin( 2*l3 - om3 - psi );
        upsilon +=   -174 * sin( 3*l3 - 7*l4 + 4*pi4 );
        upsilon +=    140 * sin( 3*l3 - 7*l4 + pi3 + 3*pi4 );
        upsilon +=    -55 * sin( 3*l3 - 7*l4 + 2*pi3 + 2*pi4 );
        upsilon +=     27 * sin( 3*l3 - 4*l4 + pi4 );
        upsilon +=    227 * sin( 3*(l3 - l4) );
        upsilon +=     53 * sin( 4*(l3 - l4) );
        upsilon +=     13 * sin( 5*(l3 - l4) );
        upsilon +=     42 * sin( l2 - 3*l3 + 2*l4 );
        upsilon += -12055 * sin( l2 - l3 );
        upsilon +=    -24 * sin( l2 - pi3 );
        upsilon +=    -10 * sin( l2 - pi4 );
        upsilon +=    -79 * sin( 2*l2 - 3*l3 + pi4 );
        upsilon +=   -131 * sin( 2*l2 - 3*l3 + pi3 );
        upsilon +=   -665 * sin( l1 - 2*l2 + pi4 ); 
        upsilon +=  -1228 * sin( l1 - 2*l2 + pi3 ); 
        upsilon +=   1082 * sin( l1 - 2*l2 + pi2 ); 
        upsilon +=     90 * sin( l1 - 2*l2 + pi1 ); 
        upsilon +=    190 * sin( l1 - l2 );
        upsilon +=    218 * sin( l1 - l3 );
        upsilon +=      2 * sin( 2*l1 - 4*l2 + om3 + psi );
        upsilon +=     -4 * sin( 2*l1 - 4*l2 + 2*om3 );
        upsilon +=      3 * sin( 2*l1 - 4*l2 + 2*om2 );
        upsilon +=      2 * sin( 2*l1 - 4*l2 + pi3 + pi4 );
        upsilon +=      2 * sin( 2*l1 - 4*l2 + 2*pi3 );
        upsilon +=    -13 * sin( 2*(l1 - l2) );
        upsilon *= 1e-7;

        // now use the "time completed" series
        n := 50.31760920702 * deg_to_rad;
        computeArguments(t + upsilon/n, l1, l2, l3, l4, 
                         om1, om2, om3, om4, psi, Gp, G);

        zeta +=     37 * sin( l2 + psi - 2*(PIj - G) - G );
        zeta +=    321 * sin( l2 + psi - 2*(PIj - G) );
        zeta +=    -15 * sin( l2 + psi - 2*PIj - G );
        zeta +=    -45 * sin( l3 - 2*PIj + psi );
        zeta +=  -2797 * sin( l3 - om2 );
        zeta +=  32402 * sin( l3 - om3 );
        zeta +=   6847 * sin( l3 - om4 );
        zeta +=    -45 * sin( l3 - psi - G );
        zeta += -16911 * sin( l3 - psi );
        zeta +=     51 * sin( l3 - psi + G );
        zeta +=     10 * sin( 2*l2 - 3*l3 + psi );
        zeta +=    -21 * sin( 2*l2 - 3*l3 + om3 );
        zeta +=     30 * sin( 2*l2 - 3*l3 + om2 );
        zeta *= 1e-7;

        result:=true;
    end;

    CALLISTO: begin
        lon := l4;

        xi +=    -19 * cos( psi - om3 );
        xi +=    167 * cos( psi - om4 );
        xi +=     11 * cos( G );
        xi +=     12 * cos( om3 - om4 );
        xi +=    -13 * cos( pi3 - pi4 );
        xi +=   1621 * cos( l4 - pi3 );
        xi +=    -24 * cos( l4 - pi4 + 2*(psi - PIj) );
        xi +=    -17 * cos( l4 - pi4 - G );
        xi += -73546 * cos( l4 - pi4 );
        xi +=     15 * cos( l4 - pi4 + G );
        xi +=     30 * cos( l4 - pi4 + 2*(PIj - psi) );
        xi +=     -5 * cos( l4 - PIj + 2*G );
        xi +=    -89 * cos( l4 - PIj - G );
        xi +=    182 * cos( l4 - PIj );
        xi +=     -6 * cos( l4 + pi4 - 2*PIj - 4*G );
        xi +=    -62 * cos( l4 + pi4 - 2*PIj - 3*G );
        xi +=   -543 * cos( l4 + pi4 - 2*PIj - 2*G );
        xi +=     27 * cos( l4 + pi4 - 2*PIj - G );
        xi +=      6 * cos( l4 + pi4 - 2*PIj );
        xi +=      6 * cos( l4 + pi4 - om4 - psi );
        xi +=     -9 * cos( l4 + pi3 - 2*pi4 );
        xi +=     14 * cos( l4 + pi3 - PIG2 );
        xi +=     13 * cos( 2*l4 - pi3 - pi4 );
        xi +=   -271 * cos( 2*(l4 - pi4) );
        xi +=    -25 * cos( 2*l4 - PIG2 - G );
        xi +=   -155 * cos( 2*l4 - PIG2 );
        xi +=    -12 * cos( 2*l4 - om3 - om4 );
        xi +=     19 * cos( 2*l4 - om3 - psi );
        xi +=     48 * cos( 2*(l4 - om4) );
        xi +=   -167 * cos( 2*l4 - om4 - psi );
        xi +=    142 * cos( 2*(l4 - psi) );
        xi +=    -22 * cos( l3 - 2*l4 + pi4 );
        xi +=     20 * cos( l3 - 2*l4 + pi3 );
        xi +=    974 * cos( l3 - l4 );
        xi +=     24 * cos( 2*l3 - 3*l4 + pi4 );
        xi +=    177 * cos( 2*(l3 - l4) );
        xi +=      4 * cos( 3*l3 - 4*l4 + pi4 );
        xi +=     42 * cos( 3*(l3 - l4) );
        xi +=     14 * cos( 4*(l3 - l4) );
        xi +=      5 * cos( 5*(l3 - l4) );
        xi +=     -8 * cos( l2 - 3*l3 + 2*l4 );
        xi +=     92 * cos( l2 - l4 );
        xi +=    105 * cos( l1 - l4 );
        xi *= 1e-7;

        radius := axis4 * (1 + xi);

        upsilon +=      8 * sin( 2*psi - pi3 - pi4 );
        upsilon +=     -9 * sin( psi - pi3 - pi4 + om4 );
        upsilon +=     27 * sin( psi - pi3 + pi4 - om4 );
        upsilon +=   -409 * sin( 2*(psi - pi4) );
        upsilon +=    310 * sin( psi - 2*pi4 + om4 );
        upsilon +=    -19 * sin( psi - 2*pi4 + om3 );
        upsilon +=      8 * sin( 2*psi - pi4 - PIj );
        upsilon +=     -5 * sin( psi - pi4 - PIj + om4 );
        upsilon +=     63 * sin( psi - pi4 + PIj - om4 );
        upsilon +=      8 * sin( 2*psi - PIG2 - G );
        upsilon +=     73 * sin( 2*psi - PIG2 );
        upsilon +=  -5768 * sin( 2*(psi - PIj) );
        upsilon +=     16 * sin( psi + om4 - PIG2 );
        upsilon +=    -97 * sin( psi - om3 );
        upsilon +=    152 * sin( 2*(psi - om4) );
        upsilon +=   2070 * sin( psi - om4 );
        upsilon +=  -5604 * sin( G );
        upsilon +=   -204 * sin( 2*G );
        upsilon +=    -10 * sin( 3*G );
        upsilon +=     24 * sin( Gp - G + phi3 );
        upsilon +=     11 * sin( Gp + phi1 - 2*phi2 );
        upsilon +=     52 * sin( 2*(Gp - G) + phi4 );
        upsilon +=     61 * sin( 2*Gp - G + phi1 );
        upsilon +=     25 * sin( 3*Gp - 2*G + phi2 + phi3 );
        upsilon +=     21 * sin( 3*Gp - G + phi1 - phi2 );
        upsilon +=    -45 * sin( 5*Gp - 3*G + phi1 );
        upsilon +=   -495 * sin( 5*Gp - 3*G + phi2 );
        upsilon +=    -44 * sin( om3 - om4 );
        upsilon +=      5 * sin( pi4 - PIj - G );
        upsilon +=    234 * sin( pi4 - PIj );
        upsilon +=     11 * sin( 2*pi4 - PIG2 );
        upsilon +=    -10 * sin( 2*pi4 - om3 - om4 );
        upsilon +=     68 * sin( 2*(pi4 - om4) );
        upsilon +=    -13 * sin( pi3 - pi4 - om4 + psi );
        upsilon +=  -5988 * sin( pi3 - pi4 );
        upsilon +=    -47 * sin( pi3 - pi4 + om3 - om4 );
        upsilon +=  -3249 * sin( l4 - pi3 );
        upsilon +=     48 * sin( l4 - pi4 + 2*(psi - PIj) );
        upsilon +=     10 * sin( l4 - pi4 - om4 + psi );
        upsilon +=     33 * sin( l4 - pi4 - G );
        upsilon += 147108 * sin( l4 - pi4 );
        upsilon +=    -31 * sin( l4 - pi4 + G );
        upsilon +=     -6 * sin( l4 - pi4 + om4 - psi );
        upsilon +=    -61 * sin( l4 - pi4 + 2*(PIj - psi) );
        upsilon +=     10 * sin( l4 - PIj - 2*G );
        upsilon +=    178 * sin( l4 - PIj - G );
        upsilon +=   -363 * sin( l4 - PIj );
        upsilon +=      5 * sin( l4 + pi4 - 2*PIj - 5*Gp + 2*G - phi1 );
        upsilon +=     12 * sin( l4 + pi4 - 2*PIj - 4*G );
        upsilon +=    124 * sin( l4 + pi4 - 2*PIj - 3*G );
        upsilon +=   1088 * sin( l4 + pi4 - 2*PIj - 2*G );
        upsilon +=    -55 * sin( l4 + pi4 - 2*PIj - G );
        upsilon +=    -12 * sin( l4 + pi4 - 2*PIj );
        upsilon +=    -13 * sin( l4 + pi4 - om4 - psi );
        upsilon +=      6 * sin( l4 + pi4 - 2*psi );
        upsilon +=     17 * sin( l4 + pi3 - 2*pi4 );
        upsilon +=    -28 * sin( l4 + pi3 - PIG2 );
        upsilon +=    -33 * sin( 2*l4 - pi3 - pi4 );
        upsilon +=    676 * sin( 2*(l4 - pi4) );
        upsilon +=     36 * sin( 2*(l4 - PIj - G) - G );
        upsilon +=    218 * sin( 2*(l4 - PIj - G) );
        upsilon +=     -5 * sin( 2*(l4 - PIj) - G );
        upsilon +=     12 * sin( 2*l4 - om3 - om4 );
        upsilon +=    -19 * sin( 2*l4 - om3 - psi );
        upsilon +=    -48 * sin( 2*(l4 - om4) );
        upsilon +=    167 * sin( 2*l4 - om4 - psi );
        upsilon +=   -142 * sin( 2*(l4 - psi) );
        upsilon +=    148 * sin( l3 - 2*l4 + pi4 );
        upsilon +=    -94 * sin( l3 - 2*l4 + pi3 );
        upsilon +=   -390 * sin( l3 - l4 );
        upsilon +=      9 * sin( 2*l3 - 4*l4 + 2*pi4 );
        upsilon +=    -37 * sin( 2*l3 - 3*l4 + pi4 );
        upsilon +=      6 * sin( 2*l3 - 3*l4 + pi3 );
        upsilon +=   -195 * sin( 2*(l3 - l4) );
        upsilon +=      6 * sin( 3*l3 - 7*l4 + 2*pi4 + om4 + psi );
        upsilon +=    187 * sin( 3*l3 - 7*l4 + 4*pi4 );
        upsilon +=   -149 * sin( 3*l3 - 7*l4 + pi3 + 3*pi4 );
        upsilon +=     51 * sin( 3*l3 - 7*l4 + 2*(pi3 + pi4) );
        upsilon +=    -10 * sin( 3*l3 - 7*l4 + 3*pi3 + pi4 );
        upsilon +=      6 * sin( 3*(l3 - 2*l4 + pi4) );
        upsilon +=     -8 * sin( 3*l3 - 4*l4 + pi4 );
        upsilon +=    -41 * sin( 3*(l3 - l4) );
        upsilon +=    -13 * sin( 4*(l3 - l4) );
        upsilon +=    -44 * sin( l2 - 3*l3 + 2*l4 );
        upsilon +=     89 * sin( l2 - l4 );
        upsilon +=    106 * sin( l1 - l4 );
        upsilon *= 1e-7;

        // now use the "time completed" series
        n := 21.57107117668 * deg_to_rad;
        computeArguments(t + upsilon/n, l1, l2, l3, l4,
                         om1, om2, om3, om4, psi, Gp, G);

        zeta +=      8 * sin( l4 - 2*PIj - om4 - 2*psi );
        zeta +=      8 * sin( l4 - 2*PIj + psi - 4*G );
        zeta +=     88 * sin( l4 - 2*PIj + psi - 3*G );
        zeta +=    773 * sin( l4 - 2*PIj + psi - 2*G );
        zeta +=    -38 * sin( l4 - 2*PIj + psi - G );
        zeta +=      5 * sin( l4 - 2*PIj + psi );
        zeta +=      9 * sin( l4 - om1 );
        zeta +=    -17 * sin( l4 - om2 );
        zeta +=  -5112 * sin( l4 - om3 );
        zeta +=     -7 * sin( l4 - om4 - G );
        zeta +=  44134 * sin( l4 - om4 );
        zeta +=      7 * sin( l4 - om4 + G );
        zeta +=   -102 * sin( l4 - psi - G );
        zeta += -76579 * sin( l4 - psi );
        zeta +=    104 * sin(  l4 - psi + G );
        zeta +=    -10 * sin( l4 - psi + 5*Gp - 2*G + phi2 );
        zeta +=    -11 * sin( l3 - 2*l4 + psi );
        zeta +=      7 * sin( l3 - 2*l4 + om4 );
        zeta *= 1e-7;

     result:=true;
    end;
    else
         result:=false;
    end; // case b
    if result then begin
      // Jupiter equatorial coordinates
      X := radius * cos(lon - psi + upsilon);
      Y := radius * sin(lon - psi + upsilon);
      Z := radius * zeta;

      // rotate to Jupiter's orbital plane
      I := 3.10401 * deg_to_rad;
      rotateX(X, Y, Z, -I);

      // rotate towards ascending node of Jupiter's equator on its
      // orbital plane
      OM := 99.95326 * deg_to_rad;
      rotateZ(X, Y, Z, OM - psi);

      // rotate to ecliptic
      J := 1.30691 * deg_to_rad;
      rotateX(X, Y, Z, -J);

      // rotate towards ascending node of Jupiter's orbit on ecliptic
      rotateZ(X, Y, Z, -OM);

      // rotate to earth equator B1950
      eps := 23.4457889 * deg_to_rad;
      rotateX(X, Y, Z, -eps);

      // precess to J2000
      precessB1950J2000(X, Y, Z);
    end;
end;

function MarSatAll(jde: double; var xsat,ysat,zsat : double8):integer;
var i: integer;
    X,Y,Z: double;
begin
result:=0;
for i:=1 to 2 do begin
  if marsat(jde, tbody(ord(MARS)+i), X,Y,Z) then begin
    xsat[i]:=X;
    ysat[i]:=Y;
    zsat[i]:=Z;
  end
  else result:=1;
end;
end;

function JupSatAll(jde: double; var xsat,ysat,zsat : double8):integer;
var i: integer;
    X,Y,Z: double;
begin
result:=0;
for i:=1 to 4 do begin
  if jupsat(jde, tbody(ord(JUPITER)+i), X,Y,Z) then begin
    xsat[i]:=X;
    ysat[i]:=Y;
    zsat[i]:=Z;
  end
  else result:=1;
end;
end;

end.
