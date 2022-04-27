package trigonometric is

    function app_sin(x: integer) return integer;
    function app_cos(x: integer) return integer;
    
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
end package body;