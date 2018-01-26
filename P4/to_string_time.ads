with Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Unbounded;
with Gnat.Calendar.Time_IO;

package To_String_Time is

	package ASU renames Ada.Strings.Unbounded;
	package C_IO renames Gnat.Calendar.Time_IO;

	function Image_3 (T: Ada.Calendar.Time) return String;

end To_String_Time;