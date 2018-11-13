function char_guess=recognite(x)

    screen =   ['A' 'B' 'C' 'D' 'E' 'F';
                'G' 'H' 'I' 'J' 'K' 'L';
                'M' 'N' 'O' 'P' 'Q' 'R';
                'S' 'T' 'U' 'V' 'W' 'X';
                'Y' 'Z' '1' '2' '3' '4';
                '5' '6' '7' '8' '9' '_'];
        
    for i=1:12
        if x(i)<=6
            small_num=x(i);
             break
        end
    end
    
    for i=1:12
        if x(i)>6
            big_num=x(i);
             break
        end
    end
    char_guess=screen(big_num-6,small_num);
end