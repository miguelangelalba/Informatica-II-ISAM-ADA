with Ada.Text_IO;
with Ada.Calendar;

procedure Plazo is
	use type Ada.Calendar.Time;
	
	Plazo: constant Duration := 3.0;
	Intervalo: constant Duration := 0.2;
	Hora_Inicio, Hora_Fin: Ada.Calendar.Time;
	Hora_Actual, Hora_Anterior: Ada.Calendar.Time;

begin
	
	Hora_Inicio := Ada.Calendar.Clock;
	Hora_Fin := Hora_Inicio + Plazo;
	Hora_Anterior := Ada.Calendar.Clock;
	Hora_Actual := Ada.Calendar.Clock;

	while Hora_Actual < Hora_Fin loop
		if Hora_Actual - Hora_Anterior > Intervalo then
			Ada.Text_IO.Put_Line ("Han pasado ya: " &
										 Duration'Image(Hora_Actual - Hora_Inicio) &
										 " segundos");
			Hora_Anterior := Hora_Actual;
		end if;
      Hora_Actual := Ada.Calendar.Clock;
   end loop;

   Ada.Text_Io.Put_Line("Fin.");

end Plazo;

