library work;
use work.common.all;
package trigonometric is

    function app_sin(x: integer) return integer;
    function reduce_alpha(x: integer range 0 to 100) return integer;
    function app_cos(x: integer) return integer;
    function sin_from_table(x: integer range 0 to N/2-1) return integer;-- range -100 to 100;
    function cos_from_table(x: integer range 0 to N/2-1) return integer;-- range -100 to 100;

    type trig_arr is array(0 to N/2 -1 ) of integer range -512 to 512;

    -- 8
    -- constant sin_arr: trig_arr := (
    --     -- 0, -90, -128, -90
    -- );

    -- 256
    -- constant sin_arr: trig_arr := (
    --     0, -12, -25, -37, -50, -62, -75, -87, -99, -112, -124, -136, -148, -160, -172, -184, 
    --     -195, -207, -218, -230, -241, -252, -263, -273, -284, -294, -304, -314, -324, -334, -343, 
    --     -353, -362, -370, -379, -387, -395, -403, -411, -418, -425, -432, -439, -445, -451, -457, 
    --     -462, -468, -473, -477, -482, -486, -489, -493, -496, -499, -502, -504, -506, -508, -509, 
    --     -510, -511, -511, -512, -511, -511, -510, -509, -508, -506, -504, -502, -499, -496, -493, 
    --     -489, -486, -482, -477, -473, -468, -462, -457, -451, -445, -439, -432, -425, -418, -411, 
    --     -403, -395, -387, -379, -370, -362, -353, -343, -334, -324, -314, -304, -294, -284, -273, 
    --     -263, -252, -241, -230, -218, -207, -195, -184, -172, -160, -148, -136, -124, -112, -99, 
    --     -87, -75, -62, -50, -37, -25, -12
    --     -- 0, -99, -195, -284, -362, -425, -473, -502, -512, -502, -473, -425, -362, -284, -195, -99
    -- );

    -- 128
    -- constant sin_arr: trig_arr := (
    --     0, -25, -50, -75, -99, -124, -148, -172, -195, -218, -241, -263, -284, -304, -324, -343, 
    --     -362, -379, -395, -411, -425, -439, -451, -462, -473, -482, -489, -496, -502, -506, -509, 
    --     -511, -512, -511, -509, -506, -502, -496, -489, -482, -473, -462, -451, -439, -425, -411, 
    --     -395, -379, -362, -343, -324, -304, -284, -263, -241, -218, -195, -172, -148, -124, -99, 
    --     -75, -50, -25
    -- );

    -- -- 64
    -- constant sin_arr: trig_arr := (
    --     0, -50, -99, -148, -195, -241, -284, -324, -362, -395, -425, -451, -473, -489, -502, -509, 
    --     -512, -509, -502, -489, -473, -451, -425, -395, -362, -324, -284, -241, -195, -148, -99, 
    --     -50
    -- );

    -- -- 32
    constant sin_arr: trig_arr := (

        0, -99, -195, -284, -362, -425, -473, -502, -512, -502, -473, -425, -362, -284, -195, -99
    );


    -- 8
    -- constant cos_arr: trig_arr := (
    --     -- 128, 90, 0, -90
    -- );

    -- 256
    -- constant cos_arr: trig_arr := (
    --     512, 511, 511, 510, 509, 508, 506, 504, 502, 499, 496, 493, 489, 486, 482, 477, 
    --     473, 468, 462, 457, 451, 445, 439, 432, 425, 418, 411, 403, 395, 387, 379, 
    --     370, 362, 353, 343, 334, 324, 314, 304, 294, 284, 273, 263, 252, 241, 230, 
    --     218, 207, 195, 184, 172, 160, 148, 136, 124, 112, 99, 87, 75, 62, 50, 
    --     37, 25, 12, 0, -12, -25, -37, -50, -62, -75, -87, -99, -112, -124, -136, 
    --     -148, -160, -172, -184, -195, -207, -218, -230, -241, -252, -263, -273, -284, -294, -304, 
    --     -314, -324, -334, -343, -353, -362, -370, -379, -387, -395, -403, -411, -418, -425, -432, 
    --     -439, -445, -451, -457, -462, -468, -473, -477, -482, -486, -489, -493, -496, -499, -502, 
    --     -504, -506, -508, -509, -510, -511, -511
    -- );

    -- 128
    -- constant cos_arr: trig_arr := (
    --     512, 511, 509, 506, 502, 496, 489, 482, 473, 462, 451, 439, 425, 411, 395, 379, 
    --     362, 343, 324, 304, 284, 263, 241, 218, 195, 172, 148, 124, 99, 75, 50, 
    --     25, 0, -25, -50, -75, -99, -124, -148, -172, -195, -218, -241, -263, -284, -304, 
    --     -324, -343, -362, -379, -395, -411, -425, -439, -451, -462, -473, -482, -489, -496, -502, 
    --     -506, -509, -511
    -- );

    -- -- 64
    -- constant cos_arr: trig_arr := (
    --     512, 509, 502, 489, 473, 451, 425, 395, 362, 324, 284, 241, 195, 148, 99, 50, 
    --     0, -50, -99, -148, -195, -241, -284, -324, -362, -395, -425, -451, -473, -489, -502, 
    --     -509
    -- );

    -- 32
    constant cos_arr: trig_arr := (
        512, 502, 473, 425, 362, 284, 195, 99, 0, -99, -195, -284, -362, -425, -473, -502
    );

end package trigonometric ;

package body trigonometric is

    -- approximated sin function: app_sin(x) = 100 * sin(0.1 * x)
    function app_sin(x: integer) return integer is
        variable y, tmp: integer := 0;
        variable div, x01, x100000: integer := 0;
        begin
            x100000 := x*10000;
            div := integer(x100000 /157079);
            x01 :=  integer((x100000 -div*157079)/1000);
			if div mod 4 = 1 or div mod 4 = 3 then
                x01  := 157 - x01;
            end if;
            y := x01 - (x01**3)/60000;
            tmp := x01**3/12000;
            tmp := (tmp * (x01**2))/1000;
            y := y + tmp/1000;
				
            if div mod 4 = 2 or div mod 4 = 3 then
                y := y * (-1);
            end if;
            return y;
        end function;

        -- approximated cos function: app_cos(x) = 100 * cos(0.1 * x)
        function app_cos(x: integer) return integer is
            variable y, tmp: integer := 0;
            variable div, x01, x100000: integer := 0;
            begin
                x100000 := x*10000;
                div := integer(x100000 /157079);
                x01 :=  integer((x100000 -div*157079)/1000);
                if div mod 4 = 1 or div mod 4 = 3 then
                    x01  := 157 - x01;
                end if;
                y := 100 - (x01**2)/200;
                tmp := x01**4/240;
                tmp := tmp/100;
                y := y + tmp/1000;
                    
                if div mod 4 = 1 or div mod 4 = 2 then
                    y := y * (-1);
                end if;
                return y;
            end function;

        function sin_from_table(x: integer range 0 to N/2-1) return integer is -- range -100 to 100 is
        begin
            return sin_arr(x);
        end function;

        function cos_from_table(x: integer range 0 to N/2-1) return integer is -- range -100 to 100 is
            begin
                return cos_arr(x);
        end function;

            function reduce_alpha(x: integer range 0 to 100) return integer is
                variable y, tmp: integer range 0 to 100 := 0;
                variable div, x01, x100000: integer range 0 to 100 := 0;
                begin
                    -- x100000 := x*10000;
                    div := x /157;
                    x01 :=  x mod 157;--integer((x100000 -div*157079)/1000);
                    if div mod 4 = 1 or div mod 4 = 3 then
                        x01  := 157 - x01;
                    end if;
                    return x01;
                    -- y := x01 - (x01**3)/60000;
                    -- tmp := x01**3/12000;
                    -- tmp := (tmp * (x01**2))/1000;
                    -- y := y + tmp/1000;
                        
                    -- if div mod 4 = 2 or div mod 4 = 3 then
                    --     y := y * (-1);
                    -- end if;
                    -- return y;
                end function;
end package body;