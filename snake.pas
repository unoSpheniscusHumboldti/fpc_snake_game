program snake_linked_list;

uses crt, process;

label
	loop_exit, loop_exit_2;

const
	star = '*';

type
//double linked list for snake;
	pointer = ^record_4;
	record_4 = record
		x,y: integer;
		prev, next: pointer;
	end;

	deque = record
		first, last: pointer;
	end;

//linked list for targets;
	pointer_typ = ^record_3;
	record_3 = record
		x,y: integer;
		next: pointer_typ;
	end;
	
	direction = record
		x: integer;
		y: integer;
	end;
	
procedure show_object(x,y: integer);
	begin
		GotoXY(x,y);
		write(star);
		GotoXY(1,1)
	end;

procedure hide_object(x,y: integer);
      begin
            GotoXY(x,y);
            write(' ');
            GotoXY(1,1)
      end;

procedure show_message(msg: string);
	var
		len: integer;
	begin
		len := length(msg);
		clrscr;
		GotoXY((ScreenWidth-len) div 2, ScreenHeight div 2);
		write(msg);
		GotoXY(1,1);
		delay(3000);
		clrscr 
	end;

procedure end_program(i: integer);
	begin
		clrscr;
		case i of
			1: begin
				show_message('see you soon!');
				//halt
			end;
			2: begin
				show_message('ooops');
				halt
			end;
			3: show_message('win-win!')
		end;
	end;

procedure show_target(var t: pointer_typ); //returns pointer to the fitst element of linked list with coordinates of targets
	var
		temp: pointer_typ;
		i: integer;
	begin
		t := nil;
		randomize;
		
		for i := 0 to 14 do begin
			new(temp);
			temp^.x := random(ScreenWidth);
			temp^.y := random(ScreenHeight);
			temp^.next := t;
			t := temp;
			show_object(t^.x, t^.y)
		end;
	end;

procedure move(var s: deque; d: direction);
	var
		temp: pointer;
	begin
		temp := s.first;
		
		while temp <> nil do begin 
			hide_object(temp^.x, temp^.y);
			temp := temp^.next
		end;
		
		temp := s.last;
		while temp^.prev <> nil do begin
			temp^.x := temp^.prev^.x;
			temp^.y := temp^.prev^.y;
			temp := temp^.prev
		end;
		s.first^.x := s.first^.x + d.x;
		s.first^.y := s.first^.y + d.y;
		temp := s.first;
        
		while temp <> nil do begin
			show_object(temp^.x, temp^.y);
			temp := temp^.next
		end;
	end;

procedure new_snake_element(var s: deque; x,y: integer); 
//adding a new element to the nail of snake;
	var
		temp: pointer;		
	begin
			new(temp);
			temp^.x := x;
			temp^.y := y;
			temp^.prev := s.last;
			temp^.next := nil;
			
			if s.last = nil then
				s.first := temp
			else
				s.last^.next := temp;
			s.last := temp
	end;

procedure start_new_game(var t: pointer_typ; var s: deque);
	begin
		show_message('you wanna play - lets play!(c)');
		t := nil;
		show_target(t);
		s.first := nil;
		s.last := nil;
		new_snake_element(s, ScreenWidth div 2, ScreenHeight div 2);
	end;

procedure reset_term;
	var
		reset_process: TProcess;
	begin
		reset_process := TProcess.Create(nil);
		reset_process.Executable := 'reset';
		reset_process.Options := reset_process.Options + [poWaitOnExit];
		reset_process.Execute;
		reset_process.Free
	end;

var
	target, temp: pointer_typ;
	snake: deque;
	delay_duration, count: integer;
	ch: char;
	dir: direction;

begin
	count := 1;
	delay_duration := 50;
	TextColor(Green);
	TextBackground(Black);
	show_message('welcome to snake game! use arrow keys for playing!');
	start_new_game(target, snake);

    
	while true do begin
		
		if (snake.first^.x > ScreenWidth) or
		   (snake.first^.x < 1) or
		   (snake.first^.y > ScreenHeight) or
		   (snake.first^.y < 1) then begin
			show_message('ooops, but you have to try again');
			dir.x := 0;
			dir.y := 0;
			start_new_game(target, snake);
			delay_duration := 50;
			count := 1
		end;

		temp := target;
		while temp <> nil do begin
			if (temp^.x = snake.first^.x) and (temp^.y = snake.first^.y) then begin
				count := count + 1;
				
				if count = 10 then begin
					end_program(3);	
					goto loop_exit_2;
				end;

				GotoXY(15,1);
				write(count);
				delay_duration := delay_duration - 5; 
				temp^.x := 0;
				temp^.y := 0;
				new_snake_element(snake, snake.first^.x - dir.x, snake.first^.y - dir.y);
				goto loop_exit
			end;
			temp := temp^.next
		end;
		loop_exit:
		
		if not Keypressed then begin
			move(snake, dir);
			delay(delay_duration);
			continue
		end;

		ch := ReadKey;
		case ch of
			#75: begin
				dir.x := -1;
				dir.y := 0;
			end;
			#77: begin
				dir.x := 1;
				dir.y := 0;
			end;
			#72: begin
				dir.x := 0;
				dir.y := -1;
			end;
			#80: begin
				dir.x := 0;
				dir.y := 1;
			end;
			' ': begin
				dir.x := 0;
				dir.y := 0;
			end;
			#27: begin
				end_program(1);
				break;
			end;
		end;
    end;

	loop_exit_2:
	delay(1000);
	reset_term;
end.
