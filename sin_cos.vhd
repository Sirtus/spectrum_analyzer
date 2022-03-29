package sin_cos is
    
    type sin_cos_arr_t is array(0 to 62) of integer range -100 to 100;

    constant sin_arr: sin_cos_arr_t := 
    (
        0 , 9 , 19 , 29 , 38 , 47 , 56 , 64 , 71 , 78 , 
        84 , 89 , 93 , 96 , 98 , 99 , 99 , 99 , 97 , 94 , 
        90 , 86 , 80 , 74 , 67 , 59 , 51 , 42 , 33 , 23 , 
        14 , 4 , -5 , -15 , -25 , -35 , -44 , -52 , -61 , -68 , 
        -75 , -81 , -87 , -91 , -95 , -97 , -99 , -99 , -99 , -98 , 
        -95 , -92 , -88 , -83 , -77 , -70 , -63 , -55 , -46 , -37 , 
        -27 , -18 , -8 
    );

    constant cos_arr: sin_cos_arr_t := 
    (
        100 , 99 , 98 , 95 , 92 , 87 , 82 , 76 , 69 , 62 , 
        54 , 45 , 36 , 26 , 16 , 7 , -2 , -12 , -22 , -32 , 
        -41 , -50 , -58 , -66 , -73 , -80 , -85 , -90 , -94 , -97 , 
        -98 , -99 , -99 , -98 , -96 , -93 , -89 , -84 , -79 , -72 , 
        -65 , -57 , -49 , -40 , -30 , -21 , -11 , -1 , 8 , 18 , 
        28 , 37 , 46 , 55 , 63 , 70 , 77 , 83 , 88 , 92 , 
        96 , 98 , 99
    );

    function sin(x: integer) return integer;
    function cos(x: integer) return integer;


end package sin_cos;

package body sin_cos is
    
    function sin(x: integer) return integer is
        begin
            return sin_arr((x mod 62));
    end function;

    function cos(x: integer) return integer is
        begin
            return cos_arr((x mod 62));
    end function;


end package body sin_cos;